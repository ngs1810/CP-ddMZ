#!/bin/bash

## Script for genotyping SVs with delly
## Date: 24 April 2018 
##
## Example usage:
## INDIR=/data/neurogenetics/alignments/Illumina/genomes/allGenomes SITELIST=/fast/users/a1211880/outputs/SVcalling/dellyOut/sites.bcf sbatch --array 0-125 dellyGenotype.sh

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
DELLYEXE=/data/neurogenetics/executables/delly-0.7.8/delly_v0.7.8_parallel_linux_x86_64bit
INDIR=/data/neurogenetics/alignments/Illumina/genomes/CPtwins
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut
GENOMEDIR=/fast/users/a1742674/reference
SITELIST=/fast/users/a1742674/outputs/SVcalling/dellyOut

# define query bam files
QUERIES=($(ls $INDIR/*.bam | xargs -n 1 basename))

# run the thing

### SV discovery/calling phase ###
echo $(date +"[%b %d %H:%M:%S] Starting delly genotyping")
echo "Processing file: "${QUERIES[$SLURM_ARRAY_TASK_ID]}

$DELLYEXE call \
-g ${GENOMEDIR}/hs37d5.fa.gz \
-v ${SITELIST}/sites.bcf \
-o ${OUTDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]}.geno.bcf \
-x ${GENOMEDIR}/excludeTemplates/human.hg19.excl.tsv \
${INDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]} \
2>${OUTDIR}/${QUERIES[$SLURM_ARRAY_TASK_ID]}.dellyGen.log

echo $(date +"[%b %d %H:%M:%S] All done!")
