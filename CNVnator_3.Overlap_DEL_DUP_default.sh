#!/bin/bash
## Script to identify overlaps : (Twin_1 VS (Parents)) VS Twin_2 for CNVnator only (DUP and DUP)
##
## Date: 15 May 2019
##
## Example usage: INDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed sbatch  Overlap_4_160519.sh

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
INDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed_3/In-house_filtered_2
OUTDIR=/fast/users/a1742674/outputs/cnvnator_2_080519/subset/bed_3/In-house_filtered_2/DEL_DUP_default

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi 
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR 
fi

##Start of the script###

cd ${INDIR}

#select only *vcf.bed files of six twin-1 individuals with 2 different SV (DEL and DUP)
Q=$(ls *-1*.inhousefiltered.bed | sort | uniq) 

echo "$Q"

for V in $Q;
	do
	(
		
			
		###1.define familyID using the filename of twin-1 (V2038-1.DUP.vcf.bed --> V2038)
			familyID=$(basename "$V" | cut -f1 -d "-")	
			echo "$familyID"

		###2.Define type of structural variant from each query (V2038-1.DUP.vcf.bed --> DUP)
			S=$(basename "$V" | cut -f2 -d ".")	
			echo "$S"

			#######Assign members to respective IDs
				Twin_1=$familyID-1.$S.inhousefiltered.bed
					echo "Proband :$Twin_1"
				Dad=$familyID-2.$S.inhousefiltered.bed
					echo "Dad :$Dad"
				Mum=$familyID-3.$S.inhousefiltered.bed
					echo "Mum :$Mum"
				Twin_2=$familyID-4.$S.inhousefiltered.bed
					echo "Unaffected twin :$Twin_2"
				
		echo "Processing for $familyID"
		
			bedtools intersect -a $Twin_1 -b $Dad $Mum -wao > ${OUTDIR}/1.$familyID.$S.parents.bed
		
		cd ${OUTDIR}

		#3.Are the variants of proband are also found in parents or de novo?
			cat 1.$familyID.$S.parents.bed | awk '{if ($5 == ".") print $1, $2, $3, $4}' | tr " " "\t" > 2.$familyID.$S.DNV.bed
			cat 1.$familyID.$S.parents.bed | awk '{if ($5 != ".") print $1, $2, $3, $4}' | tr " " "\t" > 3.$familyID.$S.INH.bed
		wait
		#4.Are the denovo variants found in both twins or only in proband?
			bedtools intersect -a 2.$familyID.$S.DNV.bed -b  ${INDIR}/$Twin_2 -wao > 4.$familyID.$S.Twin.DNV.bed
			cat 4.$familyID.$S.Twin.DNV.bed | awk '{if ($5 == ".") print $1, $2, $3, $4}' | tr " " "\t" > 5.$familyID.$S.Discordant.DNV.bed
			cat 4.$familyID.$S.Twin.DNV.bed | awk '{if ($5 != ".") print $1, $2, $3, $4}' | tr " " "\t" > 6.$familyID.$S.Shared.DNV.bed
		wait
		#5.Are Inherited variants found in both twins or only in proband?
			bedtools intersect -a 3.$familyID.$S.INH.bed -b  ${INDIR}/$Twin_2 -wao > 7.$familyID.$S.Twin.INH.bed
			cat 7.$familyID.$S.Twin.INH.bed | awk '{if ($5 == ".") print $1, $2, $3, $4}' | tr " " "\t" > 8.$familyID.$S.Discordant.INH.bed
			cat 7.$familyID.$S.Twin.INH.bed | awk '{if ($5 != ".") print $1, $2, $3, $4}' | tr " " "\t" > 9.$familyID.$S.Shared.INH.bed
	
		echo "Intersecting deletions of $familyID done"
	)  
	done
echo "done"
