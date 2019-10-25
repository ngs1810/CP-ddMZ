#!/bin/bash

## Script for calling SVs with delly
## Date: 28 March 2018 
##
## Example usage:
## INDIR=/data/neurogenetics/alignments/Illumina/genomes/allGenomes sbatch --array 0-126 dellyCall.sh

#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=1-00:00
#SBATCH --mem=32GB

#Notification configuration 
#SBATCH --mail-type=END                                         
#SBATCH --mail-type=FAIL                                        
#SBATCH --mail-user=a1742674@student.adelaide.edu.au

#define key variables

DELLYEXE=/data/neurogenetics/executables/delly-0.7.8/delly_v0.7.8_parallel_linux_x86_64bit
INDIR=/data/neurogenetics/alignments/Illumina/genomes/CPtwins
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut
GENOMEDIR=/fast/users/a1742674/reference

# define query bam files
QUERIES=($(ls $INDIR/*.bam | xargs -n 1 basename))

# load modules
module load BCFtools/1.3.1-GCC-5.3.0-binutils-2.25

# run the thing

### SV discovery/calling phase ###
echo $(date +"[%b %d %H:%M:%S] Starting delly")
echo "Processing file: "${QUERIES[$SLURM_ARRAY_TASK_ID]}

$DELLYEXE call \
-g ${GENOMEDIR}/human_g1k_v37.fasta \
-t DEL \
-o ${OUTDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]}.bcf \
-x ${GENOMEDIR}/excludeTemplates/human.hg19.excl.tsv \
${INDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]} \
2>${FASTDIR}/outputs/SVcalling/dellyLog/DEL/${QUERIES[$SLURM_ARRAY_TASK_ID]}.log

echo $(date +"[%b %d %H:%M:%S] All done!")
