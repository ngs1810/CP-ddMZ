#!/bin/bash
## Script for merging SVs with delly
## Date: 24 April 2018
##
## Example usage:
## INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut sbatch dellyMerge.sh
#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=1-00:00
#SBATCH --mem=8GB
# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=a1742674@adelaide.edu.au

# define key variables
DELLYEXE=/data/neurogenetics/executables/delly-0.7.8/delly_v0.7.8_parallel_linux_x86_64bit
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut
GENOMEDIR=/fast/users/a1742674/reference

# load modules
module load BCFtools/1.3.1-GCC-5.3.0-binutils-2.25

# run the thing
echo $(date +"[%b %d %H:%M:%S] Got to dir")
cd $INDIR
pwd

# filter bams to only retain chr1-22,X,Y
# because different hg19 references have diff alt contigs
# and this will make delly merge fail
echo $(date +"[%b %d %H:%M:%S] Restricting variants to chr1-22,X,Y")
for i in *.bam.bcf; do bcftools view $i --regions 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y -O b -o ${i%.bam.bcf}.filtered.bcf; done

# set the list of bams to merge
echo $(date +"[%b %d %H:%M:%S] Set bcf list")
bcfList=$(find *filtered.bcf)
echo $bcfList

# merge bams
# n increases the max SV size to 100000000
echo $(date +"[%b %d %H:%M:%S] Merge all bcfs")
$DELLYEXE merge -n 100000000 -o sites.bcf $bcfList
echo $(date +"[%b %d %H:%M:%S] All done!")
