#!/bin/bash
#SBATCH -J Mutect2
#SBATCH -o /fast/users/a1742674/outputs/SomaticVcalling/slurm-%j.out
#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --time=48:00:00
#SBATCH --mem=8GB

# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=nandini.sandran@adelaide.edu.au

# load modules
module load Java/1.8.0_121
module load GATK/4.0.0.0-Java-1.8.0_121
module load SAMtools

# run the executable
# A script to call somatic variants gatk Mutect2, designed for the Phoenix supercomputer

usage()
{
echo "# A script to call somatic variants gatk Mutect2, designed for the Phoenix supercomputer
# Requires: GATK and a list of samples
#
# Usage sbatch --array 0-(nSamples-1) $0  -b /path/to/bam/files [-o /path/to/output] | [ - h | --help ]
#
# Options
# -S    REQUIRED. List of sample ID in a text file
# -b    REQUIRED. /path/to/bamfiles.bam. Path to where you want to find your bam files. Every file matching a sample ID will be used.
# -O    OPTIONAL. Path to where you want to find your file output (if not specified current directory is used)
# -h or --help  Prints this message.  Or if you got one of the options above wrong you'll be reading this too!
#
#
# Original: Derived from GATK.HC.Phoenix by Mark Corbett, 16/11/2017
# Modified: (Date; Name; Description)
# 21/06/2018; Mark Corbett; Modify for Haloplex
# 09/07/2018; Clare van Eyk; modify for use with Mutect2 command from GATK
# 09/08/2019; Clare van Eyk; modify to call somatic variants with PONs and gnomad frequencies
# 19/08/2019; Nandini Sandran; modify to call somatic variants in ddMZ, using disease-twin as tumour, normal twin as normal :P
"
}

## Define directories ##
BAMDIR=/data/neurogenetics/alignments/Illumina/genomes/CPtwins
OUTDIR=/fast/users/a1742674/outputs/SomaticVcalling/Mutect2_2
PONDIR=/data/neurogenetics/variants/vcf
POPDIR=/data/neurogenetics/RefSeq/GATK/b37
REFDIR=/data/biohub/Refs/human/gatk_bundle/2.8/b37
TEMDIR=$OUTDIR/tempdir

## Check directories ##
if [ ! -d $BAMDIR ]; then
    echo "$INDIR not found. Please check you have the right one."
        exit 1
fi

if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
fi

if [ ! -d $TEMDIR ]; then
    mkdir -p $TEMDIR
fi

#define query bam files
cd $BAMDIR
QUERIES=$(ls $BAMDIR/*.bam | xargs -n 1 basename| cut -f1 -d "-")

## Start of the script ##
###On each sample###
##might need to change for each sample

gatk Mutect2 \
-R $REFDIR/human_g1k_v37_decoy.fasta \
-I V2038-1.dedup.realigned.recalibrated.bam \
-I V2038-4.dedup.realigned.recalibrated.bam \
-tumor V2038-1 \
-normal V2038-4 \
--germline-resource $POPDIR/somatic-b37_af-only-gnomad.raw.sites.vcf \
--panel-of-normals $PONDIR/pon.vcf.gz \
--af-of-alleles-not-in-resource -1 \
--max-population-af 0.02 \
-O $OUTDIR/V2038.mosaic.PONs_gnomad.vcf
-bamout V2038_tumor_normal_m2.bam

