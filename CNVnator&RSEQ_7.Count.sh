#!/bin/bash
## Script to tabulate variant counts of CNVnator after hard-filtering
##
## Date: 07 June 2019
## Modified
##
## 

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
INDIR=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator
OUTDIR=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator/COUNTS

## Check directories ##
if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
	exit 1
fi
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

## Start of the script
#creating table headers

	echo -e "ALL possible variants-CNVnator after hardfiltering" > ${OUTDIR}/CNVnator_hardfiltered.txt

	echo -e "Family\tDEL\t\t\t\t\t\t\t\tDUP\t\t\t\t\t\t\t" >> ${OUTDIR}/CNVnator_hardfiltered.txt
	echo -e "\tDNV\t\t\t\tINH\t\t\t\tDNV\t\t\t\tINH\t\t\t" >> ${OUTDIR}/CNVnator_hardfiltered.txt
	echo -e "\tDisc\t\tSha\t\tDisc\t\tSha\t\tDisc\t\tSha\t\tDisc\t\tSha\t" >> ${OUTDIR}/CNVnator_hardfiltered.txt
	echo -e "\tBef\tAft\tBef\tAft\tBef\tAft\tBef\tAft\tBef\tAft\tBef\tAft\tBef\tAft\tBef\tAft" >> ${OUTDIR}/CNVnator_hardfiltered.txt
	
cd ${INDIR}

#define families needed
FAMILY=$(ls *.DEL.*.bed | cut -f2 -d "." | sort | uniq )

for F in $FAMILY;
			do
			(	
				#define variables
				
				A1=$( cat 5.$F.DEL.*.bed | sort | uniq | wc -l )
				B1=$( cat 6.$F.DEL.*.bed | sort | uniq | wc -l )
				C1=$( cat 8.$F.DEL.*.bed | sort | uniq | wc -l )
				D1=$( cat 9.$F.DEL.*.bed | sort | uniq | wc -l )
				E1=$( cat 5.$F.DUP.*.bed | sort | uniq | wc -l )
				F1=$( cat 6.$F.DUP.*.bed | sort | uniq | wc -l )
				G1=$( cat 8.$F.DUP.*.bed | sort | uniq | wc -l )
				H1=$( cat 9.$F.DUP.*.bed | sort | uniq | wc -l )
				
				cd ${INDIR}/Final_Annotated/Filtered_060619
				
				A2=$( grep "full"  5.$F.DEL.*.tsv | sort | uniq | wc -l )
				B2=$( grep "full"  6.$F.DEL.*.tsv | sort | uniq | wc -l )
				C2=$( grep "full"  8.$F.DEL.*.tsv | sort | uniq | wc -l )
				D2=$( grep "full"  9.$F.DEL.*.tsv | sort | uniq | wc -l )
				E2=$( grep "full"  5.$F.DUP.*.tsv | sort | uniq | wc -l )
				F2=$( grep "full"  6.$F.DUP.*.tsv | sort | uniq | wc -l )
				G2=$( grep "full"  8.$F.DUP.*.tsv | sort | uniq | wc -l )
				H2=$( grep "full"  9.$F.DUP.*.tsv | sort | uniq | wc -l )
				
				echo -e "$F\t$A1\t$A2\t$B1\t$B2\t$C1\t$C2\t$D1\t$D2\t$E1\t$E2\t$F1\t$F2\t$G1\t$G2\t$H1\t$H2" >> ${OUTDIR}/CNVnator_hardfiltered.txt
			)
			done
echo "done"
