#!/bin/bash
# A script to call variants using the GATK v3.x best practices designed for the eResearchSA supercomputer but will work on stand alone machines too

# Variables that usually don't need changing once set for your system
gVcfFolder=/home/neuro/Documents/gVcfFileLibrary # A place to dump gVCFs for later genotyping
BWAINDEX=hg19_1stM_unmask_ran_all.fa # name of the genome reference
GATKPATH=/opt/gatk # Where the GATK program.  Be mindful that GATK is under rapid development so things may change over time!
GATKREFPATH=~/Public/RefSeqIndexAllPrograms/GATK #Refseq index library locations
GATKINDEX=$BWAINDEX # Base name of GATK indexes (usually the same as the $BWAINDEX
ChrIndexPath=$GATKREFPATH/$BWAINDEX.chridx #Location of index bed files
arrIndexBedFiles=$(ls $ChrIndexPath | grep of24.bed) #Turn the list into an array
SCRIPTPATH=~/Documents/Scripts/local # Where other general accessory scripts are
BUILD=$(echo $BWAINDEX | awk '{print substr($1, 1, length($1) - 3)}') # Genome build used = $BWAINDEX less the .fa, this will be incorporated into file names.

usage()
{
echo "# A script to call variants using the GATK v3.x best practices designed for the eResearchSA supercomputer but will work on stand alone machines too
# Requires: GATKv3.x, BWA-Picard-GATK-CleanUp.sh.  
# This script assumes you are running it because the longer BWA-GATK pipeline failed.
# Assumes your .bam file is of the form \$OUTPREFIX.realigned.recal.sorted.bwa.\$BUILD.bam and is in current directory
#
# Usage $0 -p file_prefix [ -i /path/to/bam/file -o /path/to/output] | [ - h | --help ]
#
# Options
# -p	A prefix to your sequence files of the form PREFIX_R1.fastq.gz
# -i	Path to where your .bam files are (if not set the current directory is used)
# -o	Path to where you want to find your file output (if not specified current directory is used)
# -h or --help	Prints this message.  Or if you got one of the options above wrong you'll be reading this too!
# 
# System variables currently set:
# gVcfFolder=$gVcfFolder
# ChrIndexPath=$ChrIndexPath
# IndexBedFiles=$IndexBedFiles
# GATKPATH=$GATKPATH
# GATKREFPATH=$GATKREFPATH
# GATKINDEX=$GATKINDEX
# SCRIPTPATH=$SCRIPTPATH
# BUILD=$BUILD
# 
# Original: Mark Corbett, 01/04/2014, no fooling!
# Modified: (Date; Name; Description)
# 19/09/2014; Mark Corbett; Forked from GATKv3.x.HC.HPC.sh yarr!
# 23/09/2015; Mark Corbett; Change variable for location of bam files from \$WORKDIR to \$BAMDIR specifiy with -i on command line
# 24/09/2015; Mark Corbett; bgzip final output
# 08/11/2016; Mark Corbett; Bring up to date with GATKv3.6
#
"
}

## Set Variables ##
while [ "$1" != "" ]; do
	case $1 in
		-p )			shift
					OUTPREFIX=$1
					;;
		-i )			shift
					BAMDIR=$1
					;;
		-o )			shift
					WORKDIR=$1
					;;
		-h | --help )		usage
					exit 1
					;;
		* )			usage
					exit 1
	esac
	shift
done

if [ -z "$OUTPREFIX" ]; then # If no file prefix specified then do not proceed
	usage
	echo "#ERROR: You need to specify a file prefix (PREFIX) referring to your bam file eg. PREFIX.realigned.recal.sorted.bwa.$BUILD.bam"
	exit 1
fi
if [ -z "$BAMDIR" ]; then # If no bam directory then use current directory
	BAMDIR=$(pwd)
	echo "Expecting to find the input .bam file in the current directory"
fi
if [ -z "$WORKDIR" ]; then # If no output directory then use current directory
	WORKDIR=$(pwd)
	echo "Using current directory as the working directory"
fi

tmpDir=/tmp/$OUTPREFIX # Use a tmp directory in /tmp for all of the GATK temp files
if [ ! -d $tmpDir ]; then
	mkdir -p $tmpDir
fi

## Start of the script ##
cd $tmpDir

# As of GATK v3.x you can now run the haplotype caller directly on a single bam
# Run haplotype caller in gVCF mode split over the genome (hopefully enough variants that the HMM runs OK)
for bed in $arrIndexBedFiles; do
	mkdir -p $tmpDir/$bed
done

for bed in $arrIndexBedFiles; do
	java -Xmx4g -Djava.io.tmpdir=$tmpDir/$bed -jar $GATKPATH/GenomeAnalysisTK.jar \
	-I $BAMDIR/$OUTPREFIX.realigned.recal.sorted.bwa.$BUILD.bam \
	-R $GATKREFPATH/$GATKINDEX \
	-T HaplotypeCaller \
	-L $ChrIndexPath/$bed \
	--dbsnp $GATKREFPATH/dbsnp_138.hg19.vcf \
	--min_base_quality_score 20 \
	--emitRefConfidence GVCF \
	-o $tmpDir/$bed.$OUTPREFIX.snps.g.vcf > $tmpDir/$bed.$OUTPREFIX.pipeline.log 2>&1 &
done
wait

cat *.$OUTPREFIX.pipeline.log >> $WORKDIR/$OUTPREFIX.pipeline.log
ls | grep $OUTPREFIX.snps.g.vcf$ > $OUTPREFIX.gvcf.list.txt
sed 's,^,-V '"$tmpDir"'\/,g' $OUTPREFIX.gvcf.list.txt > $OUTPREFIX.inputGVCF.txt

java -cp $GATKPATH/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants \
-R $GATKREFPATH/$GATKINDEX \
-out $gVcfFolder/$OUTPREFIX.snps.g.vcf \
$(cat $OUTPREFIX.inputGVCF.txt) \
--assumeSorted >> $WORKDIR/$OUTPREFIX.pipeline.log  2>&1

bgzip $gVcfFolder/$OUTPREFIX.snps.g.vcf
tabix $gVcfFolder/$OUTPREFIX.snps.g.vcf.gz

## Check for bad things and clean up
grep ERROR $WORKDIR/$OUTPREFIX.pipeline.log > $WORKDIR/$OUTPREFIX.pipeline.ERROR.log
if [ -z $(cat $WORKDIR/$OUTPREFIX.pipeline.ERROR.log) ]; then
	rm -r $tmpDir
else 
	echo "Some bad things went down while this script was running please see $OUTPREFIX.pipeline.ERROR.log and prepare for disappointment."
fi

