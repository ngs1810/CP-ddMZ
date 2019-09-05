#!/bin/bash
## Script to annotate SV using AnnotSV
##
## Date:23 May 2019
## 050619:Remodified to do 10% and 70% annotations at once 
## Example usage: INDIR=/fast/users/a1742674/outputs/Annotated/CNVnator_V sbatch  Annotate_cnvcalls.sh

#SBATCH -A robinson 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 8 
#SBATCH --time=02:00:00 
#SBATCH --mem=8GB
#Notification configuration
#SBATCH --mail-type=END 
#SBATCH --mail-type=FAIL 
#SBATCH --mail-user=a1742674@adelaide.edu.au 

## Define Variables ##
INDIR=/fast/users/a1742674/outputs/Annotated/050619/dellycalls_3/INV
OUTDIR_1=/fast/users/a1742674/outputs/Annotated/050619/dellycalls_3/INV/done_10%Ann_200719
OUTDIR_2=/fast/users/a1742674/outputs/Annotated/050619/dellycalls_3/INV/done_70%Ann_200719
export ANNOTSV=/fast/users/a1742674/outputs/Annotated/AnnotSV/AnnotSV_2.1

## Check directories ##

if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi

if [ ! -d $OUTDIR_1 ]; then
    mkdir -p $OUTDIR_1
fi

if [ ! -d $OUTDIR_2 ]; then
    mkdir -p $OUTDIR_2
fi

## Start of the script

cd ${INDIR}

#makesure to load modules
ml BEDTools

#To define files needed
QUERIES=$(ls V*.bed)

cd ${INDIR}

for Q in $QUERIES;
		do
		(
			#get the basename
			B=$(basename $Q .bed)
			
			echo "Annotating $Q"
			
			#run AnnotSV for 10%
			$ANNOTSV/bin/AnnotSV -SVinputFile $Q -SVinputInfo 1 -overlap 10  -outputFile ${OUTDIR_1}/$B.10%.annotated.tsv >& ${OUTDIR_1}/$B.10%.AnnotSV.log

			#run AnnotSV for 70%
                        $ANNOTSV/bin/AnnotSV -SVinputFile $Q -SVinputInfo 1 -overlap 70  -outputFile ${OUTDIR_2}/$B.70%.annotated.tsv >& ${OUTDIR_2}/$B.70%.AnnotSV.log
		)
		done
echo "done"
