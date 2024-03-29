#!/bin/bash

# Example usage:
# INDIR=/data/neurogenetics/alignments/Illumina/genomes/CPTwins ALIGNID=80 sbatch --array 0-159 retroseq.sh
# Usually set to n 16 cores, time 1 day, mem 8GB

#SBATCH -J retroseq

#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=1-00:00
#SBATCH --mem=8GB

# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=a1742674@student.adelaide.edu.au

# define key variables
INDIR=/data/neurogenetics/alignments/Illumina/genomes/CPtwins
#RETROSEQEXE=/data/neurogenetics/executables/RetroSeq/bin/retroseq.pl
RETROSEQEXE=/fast/users/a1742674/RetroSeq/bin/retroseq.pl

OUTDIR=/fast/users/a1742674/outputs/SVcalling/RetroSeq
REPEATSDIR=/fast/users/a1742674/repeats
GENOMEDIR=/data/neurogenetics/RefSeq
ALIGNID=80
# define query bam files
QUERIES=($(ls $INDIR/*.bam | xargs -n 1 basename))

# load modules
module load Exonerate/2.2.0-foss-2016uofa
module load BEDTools/2.25.0-GCC-5.3.0-binutils-2.25
module load SAMtools/0.1.19-GCC-5.3.0-binutils-2.25

# run pipeline

### discovery phase ###
echo "discovering..."
$RETROSEQEXE -discover \
-bam ${INDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]} \
-output ${OUTDIR}/TEdiscovery/${QUERIES[$SLURM_ARRAY_TASK_ID]}.candidates.tab \
-eref ${REPEATSDIR}/eref_types_a1742674.tab \
-align -id $ALIGNID \
2> ${QUERIES[$SLURM_ARRAY_TASK_ID]}.log
echo "discovery-phase done"

### filtering ###
# filter out candidates near contig starts (likely contamination)
echo "filtering contigs..."
cat ${OUTDIR}/TEdiscovery/${QUERIES[$SLURM_ARRAY_TASK_ID]}.candidates.tab \
| awk '{if ($2>1000) print}' \
> ${OUTDIR}/TEdiscovery/${QUERIES[$SLURM_ARRAY_TASK_ID]}.candidates.tab.filtered
echo "filtering done"

# (if there's no bam index file)  create bam index file
#echo "creating bai..."
#samtools index ${INDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]}
#echo "done"

### calling phase ###
echo "calling..."
$RETROSEQEXE -call \
-bam ${INDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]} \
-input ${OUTDIR}/TEdiscovery/${QUERIES[$SLURM_ARRAY_TASK_ID]}.candidates.tab.filtered \
-ref ${GENOMEDIR}/human_g1k_v37.fasta \
-output ${OUTDIR}/TEcalling/${QUERIES[$SLURM_ARRAY_TASK_ID]}.vcf \
2> ${QUERIES[$SLURM_ARRAY_TASK_ID]}.log
echo "calling done"
