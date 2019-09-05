#!/bin/bash

## Script to create BEDfiles for vcf outputs of cnvnator
##
## Date: 22 May 2019
##
## Example usage:
## INDIR=/fast/users/a1742674/outputs/SVcalling sbatch --array 0-23 countVariants_5_070519.sh

#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --time=0-30:00
#SBATCH --mem=8GB

# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=a1742674@adelaide.edu.au

#1.Start of the script
echo $(date +"[%b %d %H:%M:%S] Creating BED files")


#2. Define variables
INDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset
OUTDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed_3/single_bed
QUERIES=$(ls $INDIR/*.vcf | xargs -n 1 basename)

#3 Run a for loop

cd ${INDIR}

	cd ${INDIR}

	for Q in $QUERIES;
		do
		(
			V=$(basename $Q .vcf)
			cat $Q | cut -f1,2,8 > ${OUTDIR}/$V.temp.bed
			cat ${OUTDIR}/$V.temp.bed | tr " ; | = " "\t" > ${OUTDIR}/$V.temp2.bed
			cat ${OUTDIR}/$V.temp2.bed | cut -f1,2,4,6 > ${OUTDIR}/$V.bed

			wait

			rm ${OUTDIR}/$V.temp.bed ${OUTDIR}/$V.temp2.bed			
		) 
		done

