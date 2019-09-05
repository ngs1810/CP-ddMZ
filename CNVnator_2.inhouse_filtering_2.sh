#!/bin/bash
## Script to filter out common variants / in-house filtering
## Requiring:
## 			i. bedfiles of all individuals
##			ii. inhouse.common.variants (i.e inhouse.commonDEL.bed / inhouse.commonDUP.bed)
##
## Date: 5 June 2019
##
## Example usage: INDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed sbatch  In house filtering_2.sh

#SBATCH -A robinson 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=00:05:00 
#SBATCH --mem=8GB
#Notification configuration 
#SBATCH --mail-type=END 
#SBATCH --mail-type=FAIL 
#SBATCH --mail-user=a1742674@adelaide.edu.au 

#Load module
module load BEDTools/2.25.0-foss-2015b

## Define Variables ##
INDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed_3
OUTDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed_3/In-house_filtered_2

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi 
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR 
fi

##Start the script

cd ${INDIR}

##this is to list the 48 samples needed to be filtered
QUERIES=$(ls V*.bed)

for V in $QUERIES ;
	do
		(
			#get the sample name and  type of SV
			
			B=$(basename $V | cut -f1 -d".")
			S=$(basename $V | cut -f2 -d".")
			
			#########################to filter DEL variants and DUP variants####################
			
			#get the headers of the files and pipe them into output files
			
			grep "^#" $B.$S.bed > ${OUTDIR}/$B.$S.inhousefiltered.bed
			
			#execute bedtools intersect to identify 70% overlapped with the common variants
			
			bedtools intersect -a $B.$S.bed -b inhouse.common$S.bed -f 0.7 -r -wao > ${OUTDIR}/$B.$S.temp.bed
			
			#filter the temporary file to remove the common variants by retaining the column (1-4) if 5th column has no value ( which means no overlapping occuring here)

			cat  ${OUTDIR}/$B.$S.temp.bed | awk '{if ($8==".") print $1, $2, $3, $4}' | tr " " "\t"  >> ${OUTDIR}/$B.$S.inhousefiltered.bed

			#make sure empty spaces are replaced with tab

			#sed 's/ \+/\t/g' ${OUTDIR}/$B.$S.inhousefiltered.temp.bed >> ${OUTDIR}/$B.$S.inhousefiltered.bed
			
			cd ${OUTDIR}
	
			rm *.temp.bed
		)
	done
echo "in-house filtering done"
