#!/bin/bash
## Script to filter out common variants / in-house filtering
## Requiring:
## 			i. bedfiles of all individuals
##			ii. inhouse.common.variants (i.e inhouse.commonDEL.bed / inhouse.commonDUP.bed)
##
## Date: 5 June 2019
##
## Example usage:  sbatch  In house filtering_2.sh

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
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2
INDIR_2=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719

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

##this is to list the 6 samples needed to be filtered
QUERIES=$(ls V*.DUP.bed)

for V in $QUERIES ;
	do
		(
			#get the sample name
			
				B=$(basename $V | cut -f1 -d"_")
			
			#add one nt at each position (breakend point)
			
			#	awk 'BEGIN{FS=OFS="\t"} {$3=$2+1} {print $1,$2,$3,$4}' $V | tr " " "\t" > $B.temp1.bed			

			#get the headers of the files and pipe them into output files
			
				grep "^#" $V > ${OUTDIR}/$B.inhousefiltered.bed
			
			#execute bedtools intersect to identify 100% overlapped with the common variants
			
				bedtools intersect -a $V -b inhouse.commonDUP.delly.bed -f 0.7 -r -wao > ${OUTDIR}/$B.temp2.bed
			
			#filter the temporary file to remove the common variants by retaining the column (1-4) if 8th column has no value ( which means no overlapping occuring here)

				awk '{if ($8==".") print $1, $2, $3}' ${OUTDIR}/$B.temp2.bed >> ${OUTDIR}/$B.inhousefiltered.bed
			
			cd $OUTDIR
			
				grep "#CHROM" ${INDIR_2}/$B*.vcf > $B.DUP.GT.bed 

			#print rows with all columns of vcf file if there is matching 2nd column between vcf file and inhouse-filtered.file
			
				awk 'FNR==NR{a[$2]=$2;next} $2==a[$2] {print $0}' $B.inhousefiltered.bed ${INDIR_2}/$B*.vcf | grep -v "##" >> $B.DUP.GT.bed
			
			rm $B.temp2.bed $B.inhousefiltered.bed 
			
		)
	done
echo "in-house filtering for dellyvariants done"
