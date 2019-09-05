#!/bin/bash

## Script to create BEDfiles for vcf outputs of cnvnator
##
## Date: 9 May 2019
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
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi 

if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR 
fi

#Start Script

cd ${INDIR}

QUERIES=$(ls *.vcf)

for Q in $QUERIES;
	do
	(
	
	#get the basename
	
		B=$(basename $Q .vcf)

	#BEDfiles:Only extract column #Chromosome, #POS,and #INFO

		grep -v "##" ${INDIR}/$Q | cut -f1,2,8 | tr " ; | = " "\t" > ${OUTDIR}/$B.Temp1.bed

	cd ${OUTDIR}

	#Extract only #CHROM,#POS,#SVTYPE,#END and  value from the #INFO
		awk '{if ($5!="BND") print $1, $2, $5, $11}' $B.Temp1.bed | tr " " "\t" > $B.Temp2.bed
	
	#switch the columns of SVTYPE and END for INV
		awk -F $'\t' ' { t = $3; $3 = $4; $4 = t; print; } ' OFS=$'\t' $B.Temp2.bed > $B.Temp3.bed
	
	#extract according to different SV type

		awk '{if ($4=="DEL") print $1, $2, $3, $4}' $B.Temp3.bed | tr " " "\t" > $B.DEL.bed
		awk '{if ($4=="DUP") print $1, $2, $3, $4}' $B.Temp3.bed | tr " " "\t" > $B.DUP.bed
		awk '{if ($4=="INS") print $1, $2, $3, $4}' $B.Temp3.bed | tr " " "\t" > $B.INS.bed
		awk '{if ($4=="INV") print $1, $2, $3, $4}' $B.Temp3.bed | tr " " "\t" > $B.INV.bed
		awk '{if ($5=="BND") print $1, $2, $5, $9, $11}' $B.Temp1.bed | tr " " "\t" > $B.BND.bed
	
	wait

	rm *.Temp*

	)
	done

echo "done"

