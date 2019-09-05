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
INDIR=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator/Final_Annotated
OUTDIR=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator/Final_Annotated/Filtered_060619
OUTDIR_2=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator/Final_Annotated/OnlyVariantsAreFiltered_060619

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
			B=$(basename $Q .tsv)
			
			#insert the headers into the output file 
			grep "AnnotSV" $Q > ${OUTDIR}/$B.filtered.tsv
			
			##to choose the column, select the rows that has particular value of columns
			##$6=DEL/DUP etc
			##$7=AnnotSV type:full/split
			##$27=gnomad AF
			##$(NF-16)=pLi Exac
			##$(NF-15)=delZ_Exac
			##$(NF-14)=dupZ_Exac
			##$(NF-7)=AnnotSV ranking
			## and pipe into outputs

			#filtering both the variants and the genes in the variants
			awk 'BEGIN{FS=OFS="\t"}{if ($6=="DEL" && $27 <="0.0001" && $(NF-15)>="0" && $(NF-7)>="3" ) print}' $Q >> ${OUTDIR}/$B.filtered.tsv
			
			awk 'BEGIN{FS=OFS="\t"}{if ($6=="DUP" && $27 <="0.0001" && $(NF-14)>="0" && $(NF-7)>="3" ) print}' $Q >> ${OUTDIR}/$B.filtered.tsv
			

			#filtering only the variants, and keep the genes unfiltered
			 grep "AnnotSV" $Q > ${OUTDIR_2}/$B.filtered.tsv
			 awk 'BEGIN{FS=OFS="\t"}{if ($6=="DEL" && $27 <="0.0001" && $(NF-15)>="0" && $(NF-7)>="3" ) print}' $Q >> ${OUTDIR_2}/$B.filtered.tsv
			 awk 'BEGIN{FS=OFS="\t"}{if ($6=="DUP" && $27 <="0.0001" && $(NF-14)>="0" && $(NF-7)>="3" ) print}' $Q >> ${OUTDIR_2}/$B.filtered.tsv
			 awk 'BEGIN{FS=OFS="\t"}{if ($7=="split") print}' $Q >> ${OUTDIR_2}/$B.filtered.tsv
		)
		done
	echo "Filtering for gnomad and pLiExac and AnnotSV ranking done"
