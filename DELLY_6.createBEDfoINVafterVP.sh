#!/bin/bash

## Script to create BEDfiles for INV variants after V_P.sh, prior to annotation: to select only yhe breakend points for inversion
##
## Date: 19 July 2019
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
INDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719/V_P_INV
OUTDIR=/fast/users/a1742674/outputs/SVcalling/dellyOut/InHouse/bedfiles_2/Inhousefiltered_040719/V_P_INV/BedToAnnotate

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
        exit 1
fi

if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

#Start Script

#define files needed

cd ${INDIR}
f=$(ls *.4.* *.5.* *.8.* *.9.* *.12.* *.13.* *.16.* *.17.* )

for INV in $f ;
		do
		(
		
		Q=$( basename $INV .vcf )
		
		
		#BEDfiles:Only extract column #Chromosome, #POS,and #INFO
			grep -v "##" ${INDIR}/$INV | cut -f1,2,8 | tr " ; | = " "\t" > ${OUTDIR}/$Q.Temp1.bed

        cd ${OUTDIR}

        #Extract only #CHROM,#POS,#SVTYPE,#END and  value from the #INFO
			awk '{if ($5="INV") print $1, $2, $5, $11}' $Q.Temp1.bed | tr " " "\t" > $Q.Temp2.bed
		
		#separate the breakend points of one individual into two different bed files, followed by joining them horizontally
            cut -f1,2 $Q.Temp2.bed | tr " " "\t" > $Q.temp.sorted.bed
            grep -v "^#" $Q.Temp2.bed | cut -f1,4 | tr " " "\t" >> $Q.temp.sorted.bed

		#add one nt at each position (breakend point)
			awk 'BEGIN{FS=OFS="\t"} {$3=$2+1} {$4="INV"} {print $1,$2,$3,$4}' $Q.temp.sorted.bed | tr " " "\t" > $Q.sorted.bed
		
		wait

		#rm *Temp* *temp*

        )
        done
echo "joined two bed files of $QUERIES"
