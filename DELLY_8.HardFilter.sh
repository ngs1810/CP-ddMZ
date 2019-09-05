#!/bin/bash
## Aim : Script to do hard filtering of structural variants that have been annotated with AnnotSV
## 1. exclude variants that present commonly in various disease population (gnomad AF >=0.0001)
## 2. AnnotSV scoring to be VOUS, likely pathogenic and pathogenic (3,4,5)
## 3. Sv that have intolerant genes (ExAC pLI >=0.9) or delZ/dupZ>0 for respective variant
## 4. ( to be added soon)
##
## Date: 30 May 2019
##
## Example usage: INDIR=/fast/users/a1742674/outputs/Annotated/ sbatch  Delly_Variants.sh

#SBATCH -A robinson 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=00:05:00 
#SBATCH --mem=4GB
# Notifiion configuration 
#SBATCH --mail-type=END 
#SBATCH --mail-type=FAIL 
#SBATCH --mail-user=a1742674@adelaide.edu.au 

##define directories
INDIR=/fast/users/a1742674/outputs/Annotated/050619/dellycalls_3/Final_Annotated_200719
OUTDIR=/fast/users/a1742674/outputs/Annotated/050619/dellycalls_3/Final_Annotated_200719/Filtered_200719
OUTDIR_2=/fast/users/a1742674/outputs/Annotated/050619/dellycalls_3/Final_Annotated_200719/Filtered_200719_Final

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi

if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

if [ ! -d $OUTDIR_2 ]; then
    mkdir -p $OUTDIR_2
fi

##define files needed

cd ${INDIR}

q=$(ls *.fullAnnotated.tsv) 

	for Q in $q;
		do
		(
			#basename
			B=$(basename $Q .delly.bed.fullAnnotated.tsv)
			
			#insert the headers into the output file 
			grep "AnnotSV" $Q > ${OUTDIR}/$B.delly.fullAnnotated.filtered.tsv
			grep "AnnotSV" $Q > ${OUTDIR_2}/$B.delly.fullAnnotated.finalfiltered.tsv
			
			##to choose the column, select the rows that has particular value of columns
			
			##$27=gnomad AF
			##$(NF-16)=pLi Exac
			##$(NF-15)=delZ_Exac
			##$(NF-14)=dupZ_Exac
			##$79=AnnotSV ranking
			## and pipe into outputs

			#filtering using the gnomad and AnnotSV ranking
			awk 'BEGIN{FS=OFS="\t"}{if ($38 <="0.0001") print}' $Q >> ${OUTDIR}/$B.delly.fullAnnotated.filtered.tsv

			awk 'BEGIN{FS=OFS="\t"}{if ($38 <="0.0001" && $90>="3" ) print}' $Q >> ${OUTDIR_2}/$B.delly.fullAnnotated.finalfiltered.tsv
		
		)
		done
	echo "Filtering for gnomad and and AnnotSV ranking for dellyvariants done"
