#!/bin/bash

## Script for filtering merged SVs with the delly germline filter
## Requires at least 20 unrelated samples
## Date: 24 April 2018 
##
## Example usage:
## INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut sbatch dellyGermlineFilter.sh

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

# set variables
DELLYEXE=/data/neurogenetics/executables/delly-0.7.8/delly_v0.7.8_parallel_linux_x86_64bit
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut

# load modules
module load BCFtools/1.3.1-GCC-5.3.0-binutils-2.25

# run the thing
echo $(date +"[%b %d %H:%M:%S] Go to dir")
cd $INDIR
pwd

echo $(date +"[%b %d %H:%M:%S] Check for merged bcf")
ls merged.bcf

echo $(date +"[%b %d %H:%M:%S] Index bcf")
bcftools index merged.bcf

echo $(date +"[%b %d %H:%M:%S] Apply delly germline filter")

$DELLYEXE filter \
-f germline \
-p \
-o germline_PASS.bcf merged.bcf
# if you want to keep only variants where FILTER=PASS
# add -p to the above command

echo $(date +"[%b %d %H:%M:%S] Also output vcf")
bcftools view germline_PASS.bcf > germline_PASS.vcf

echo $(date +"[%b %d %H:%M:%S] All done!")
