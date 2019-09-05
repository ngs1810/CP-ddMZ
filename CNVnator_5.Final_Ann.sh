#!/bin/bash
## Script to generate single file that contains variants annotated with Annotations sources as listed in AnnotSV with 70% and 10% annotation of CP/Epilepsy/ID genes
##
## Date: 29 May 2019
##
## Example usage: INDIR=/fast/users/a1742674/outputs/Annotated/CNVnator_V sbatch  FinalAnn.sh

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

#define directories
INDIR=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator
OUTDIR=/fast/users/a1742674/outputs/Annotated/050619/DEL_DUP_70%_CNVnator/Final_Annotated

## Check directories ##

if [ ! -d $INDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
        exit 1
fi
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

## Start of the script
#define files needed

cd $INDIR/done_70%Ann_050619
f=$(ls *.tsv)

#1.first loop to extract columns from 70% annotated files (OUTPUT :5.V2038.DEL.Discordant.DNV.70%.temp.tsv)

        for F in $f;
                do
                (
                        #basename (5.V2038.DEL.Discordant.DNV.70%.annotated.tsv ----> 5.V2038.DEL.Discordant.DNV.70%)
                        B=$(basename $F .annotated.tsv)

                        # create first temporary file to exclude 6 columns on known disease genes from 70% annotated file without modifying the delimiters
                        cat $INDIR/done_70%Ann_050619/$F | awk 'BEGIN{FS=OFS="\t"}{$41=$42=$43=$50=$51=$52=""; print $0}' > $OUTDIR/$B.temp.tsv
                )
                done
        echo "done with excluding columns from 70% annotated files -----> $OUTDIR"

#2. extracting columns from 10% annotated files (OUTPUT :5.V2038.DEL.Discordant.DNV.10%.temp.tsv)

cd $INDIR/done_10%Ann_050619
v=$(ls *.tsv)

        for V in $v;
                do
                (
                        #basename (5.V2038.DEL.Discordant.DNV.10%.annotated.tsv -----> 5.V2038.DEL.Discordant.DNV.10%)
                        S=$(basename $V .annotated.tsv)

                        # create 2nd temporary file include first (AnnotSV, 6 columns) from 10% annotated file without modifying the delimiters
                        cat $INDIR/done_10%Ann_050619/$V | awk 'BEGIN{FS=OFS="\t"}{print $1,$41,$42,$43,$50,$51,$52}' > $OUTDIR/$S.temp.tsv
                )
                done
        echo "done with extracting columns of 10% annotated files ----> $OUTDIR"

#3.To merge the files horizontally

cd $OUTDIR

#define files to select only certain part of their names (5.V2038.DEL.Discordant.DNV.70%.annotated.tsv --> 5.V2038.DEL.Discordant.DNV) and we don't want to run for loop by duplicates
Z=$(ls *.70%.temp.tsv | sort | uniq)

                for x in $Z;
                                do
                                (
                                                # basename
                                                X=$(basename "$x" .70%.temp.tsv)

                                                echo "processing $X"

                                                #define 70% and 10% files
                                                A=$X.70%.temp.tsv
                                                B=$X.10%.temp.tsv

                                                echo " merging $A and $B vertically"

                                                # combine both files in a single .tsv file by referrign to the fist column of both files
                                                paste $A $B > $X.fullAnnotated.tsv

                                                wait

                                                #remove temp files
                                                rm $A $B
                                )
                                done
                echo "successfully merged; recheck in $OUTDIR"
