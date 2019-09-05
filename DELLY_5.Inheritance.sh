#!/bin/bash
## Script to prioritise Delly variant calls
##
## Date: 17 May 2019
##
## Example usage: INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut sbatch  Delly_Variants.sh

#SBATCH -A robinson 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 8 
#SBATCH --time=00:05:00 
#SBATCH --mem=8GB
# Notification configuration 
#SBATCH --mail-type=END 
#SBATCH --mail-type=FAIL 
#SBATCH --mail-user=a1742674@adelaide.edu.au 

## Define Variables ##
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719/Family
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719/V_P_Family

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi 

if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR 
fi

## Start of the script

cd $INDIR

#To define files needed
Q=$(ls  V*.Delly.vcf)


echo $Q


for V in $Q; #for every family-merged files
	do
	(
		#1.get the family ID :V2038_merged.bcf_germline_PASS.bed => V2038
			B=$(basename $V .Delly.vcf)		
			echo $B

		#2.exclude genotypes (0/0) from Twin_1 in column 10
			cat $V | awk '($0~/^#/)($0!~/^#/){split($10,x,":"); if(x[1]!="0/0") print }' > ${OUTDIR}/$B.1.merged.delly.vcf
		
		#2. get the headers

			grep "^#" $V > ${OUTDIR}/$B.4.Discordant.DNV.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.5.Shared.DNV.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.8.Discordant.P.INH.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.9.Shared.P.INH.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.12.Discordant.M.INH.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.13.Shared.M.INH.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.16.Discordant.bothParents.delly.vcf
			grep "^#" $V > ${OUTDIR}/$B.17.Shared.bothParents.delly.vcf	

		#3.Denovo variants ( Genotypes of both parents = 0/0)
			#excluding variants with dad's genotype (0/1, 1/1)
			cat ${OUTDIR}/$B.1.merged.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($11,x,":"); if(x[1]=="0/0") print }' > ${OUTDIR}/$B.2.temp.DNV.delly.vcf
			#excluding variants with mum's genotype (0/1, 1/1)
	  		cat ${OUTDIR}/$B.2.temp.DNV.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($12,x,":"); if(x[1]=="0/0") print }' > ${OUTDIR}/$B.3.DNV.delly.vcf
			
		#4.DENOVO & DISCORDANT variants
		##excluding variants with twin's GT (0/1, 1/1)
			cat ${OUTDIR}/$B.3.DNV.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]=="0/0") print }' >> ${OUTDIR}/$B.4.Discordant.DNV.delly.vcf
			
		#5.DENOVO & SHARED variants (Genotypes of both parents (0/0) and twin_2 != 0/0)	
			cat ${OUTDIR}/$B.3.DNV.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]!="0/0") print }' >> ${OUTDIR}/$B.5.Shared.DNV.delly.vcf
			
		#6.Paternally inherited variants
		## GT of dad (0/1,1/1) and mum (0/0)
			cat ${OUTDIR}/$B.1.merged.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($11,x,":"); if(x[1]!="0/0") print }' > ${OUTDIR}/$B.6.temp.P.INH.delly.vcf
			cat ${OUTDIR}/$B.6.temp.P.INH.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($12,x,":"); if(x[1]=="0/0") print }' > ${OUTDIR}/$B.7.P.INH.delly.vcf
			
		#7. P.INH & DISCORDANT variants
			cat ${OUTDIR}/$B.7.P.INH.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]=="0/0") print }' >> ${OUTDIR}/$B.8.Discordant.P.INH.delly.vcf
		
		#8. P.INH & Shared variants
			cat ${OUTDIR}/$B.7.P.INH.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]!="0/0") print }' >> ${OUTDIR}/$B.9.Shared.P.INH.delly.vcf
			
		#9.Maternally inherited variants	
		## GT of dad (0/0) and mum (0/1, 1/1)
			cat ${OUTDIR}/$B.1.merged.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($12,x,":"); if(x[1]!="0/0") print }' > ${OUTDIR}/$B.10.temp.M.INH.delly.vcf
			cat ${OUTDIR}/$B.10.temp.M.INH.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($11,x,":"); if(x[1]=="0/0") print }' > ${OUTDIR}/$B.11.M.INH.delly.vcf
			
		#10. M.INH & Discordant variants
			cat ${OUTDIR}/$B.11.M.INH.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]=="0/0") print }' >> ${OUTDIR}/$B.12.Discordant.M.INH.delly.vcf
		
		#11. M.INH & Shared Variants
			cat ${OUTDIR}/$B.11.M.INH.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]!="0/0") print }' >> ${OUTDIR}/$B.13.Shared.M.INH.delly.vcf
		
		#12. Exists in both parents and Discordant and shared
			cat ${OUTDIR}/$B.1.merged.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($11,x,":"); if(x[1]!="0/0") print }' > ${OUTDIR}/$B.14.temp.bothParents.delly.vcf
			cat ${OUTDIR}/$B.14.temp.bothParents.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($12,x,":"); if(x[1]!="0/0") print }' > ${OUTDIR}/$B.15.bothParents.delly.vcf
			cat ${OUTDIR}/$B.15.bothParents.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]=="0/0") print }' >> ${OUTDIR}/$B.16.Discordant.bothParents.delly.vcf
			cat ${OUTDIR}/$B.15.bothParents.delly.vcf | awk '($0~/^#/)($0!~/^#/){split($13,x,":"); if(x[1]!="0/0") print }' >> ${OUTDIR}/$B.17.Shared.bothParents.delly.vcf
		
		#rm *.2* *.3* *.6* *.7* *.10* *.11* *.14* *.15*
	)
	done
echo "done"





