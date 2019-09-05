#!/bin/bash

## Script to merge delly outputs after inhousefiltering by families
##
## Date: 19 July 2019
##
## Example usage:
## INDIR=/fast/users/a1742674/outputs/SVcalling sbatch --array 0-23 createBED_Delly.sh

#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=0-05:00
#SBATCH --mem=8GB

# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=a1742674@adelaide.edu.au

#1.Start of the script
echo $(date +"[%b %d %H:%M:%S] Creating BED files")

#2. Define variables
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719/Family

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
        exit 1
fi

if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

#Start Script

f=$(ls V*.GT.bed | cut -f1 -d "." | sort | uniq)

for F in $f;
	do
	(
		cat $F.DEL.GT.bed | tr " " "\t" > ${OUTDIR}/$F.Delly.vcf
		grep -v "^#" $F.DUP.GT.bed | tr " " "\t" >> ${OUTDIR}/$F.Delly.vcf
		grep -v "^#" $F.BND.GT.bed | tr " " "\t" >> ${OUTDIR}/$F.Delly.vcf
		grep -v "^#" $F.INS.GT.bed | tr " " "\t" >> ${OUTDIR}/$F.Delly.vcf
		#grep -v "^#" $F.INV.GT.bed | tr " " "\t" >> ${OUTDIR}/$F.Delly.vcf
	)
	done
echo "done"
