#!/bin/bash
## Script to create a minilibrary of in house variants for later part in-house filtering through AnnotSV
## Requiring:
## 			i. bedfiles of all individuals
##			ii. genome.fasta
## 			
##
## Date: 5 June 2019
## 060619 - modified for delly variants
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
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2

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

##this is to list six files to be merged
QUERIES=$(ls V*.INS.bed)

####----------->>>>1. To create the in-house common variant mini-database<<<<---------------------####
 
#merge the files and sort them numerical order/positional order per chromosome

	cat $QUERIES | sort -k1,1 -k2,2n | tr " " "\t" > All.delly.bed

#run bedtools genomecov

	bedtools genomecov -i All.delly.bed -bg -g genome.hs37d5.fa.txt > inhouse.temp.delly.bed

#give them header

	{ echo -e "#CHROM\t#START\t#END\t#Fraction" ; cat inhouse.temp.delly.bed ; } > inhouse.delly.bed

#to create common and rare variant library

	grep "#" inhouse.delly.bed  > inhouse.commonINS.delly.bed
	awk '$4>2{print$0}' inhouse.delly.bed >> inhouse.commonINS.delly.bed

echo "inhouse.delly.bed is created"

####------------_____________________----------------_____________________-------------------_____####
