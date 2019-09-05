#!/bin/bash
## Script to perform create in-house library for BND as 
## Requiring:
## 			i. bedfiles of all individuals
##			ii. inhouse.common.variants (i.e inhouse.commonDEL.bed / inhouse.commonDUP.bed)
##
## Date: 12 June 2019
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

##this is to list the 6 samples needed to be filtered
QUERIES=$(ls V*.BND.bed)

####----------->>>>1. separate the breakend points of one individual into two different bed files, followed by joining them horizontally<<<<---------------------####
for Q in $QUERIES;
	do
	(
		V=$(basename $Q .bed)
		
		cut -f1,2 $Q | tr " " "\t" > $V.sorted.bed
		cut -f4,5 $Q | tr " " "\t" >> $V.sorted.bed
		
	)
	done
echo "joined two bed files of $QUERIES"

####----------->>>>2. To create the in-house common variant mini-database<<<<---------------------####
QUERIES_2=$(ls V*.BND.sorted.bed)

#merge the files and sort them numerical order/positional order per chromosome, add one nucleotide ( which will be $END)

        	cat $QUERIES_2 | sort -k1,1 -k2,2n | tr " " "\t" > All.BND.delly.bed
		awk 'BEGIN{FS=OFS="\t"} {$3=$2+1} {print $1,$2,$3,$4}' All.BND.delly.bed | tr " " "\t" > All.BND.delly.sorted.bed


#run bedtools genomecov

        	bedtools genomecov -i All.BND.delly.sorted.bed -bg -g genome.hs37d5.fa.txt > inhouse.temp.BND.delly.bed

#give them header

		{ echo -e "#CHROM\t#START\t#END\t#Fraction" ; cat inhouse.temp.BND.delly.bed ; } > inhouse.BND.delly.bed

#to create common and rare variant library

		grep "#" inhouse.BND.delly.bed  > inhouse.commonBND.delly.bed
		awk '$4>2{print$0}' inhouse.BND.delly.bed >> inhouse.commonBND.delly.bed

#awk '$4<8{print$0}' inhouse.delly.bed >> inhouse.raredelly.bed

		echo "inhouse.delly.bed is created"
