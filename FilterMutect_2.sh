#!/bin/sh
#SBATCH -J FilterMutect2
#SBATCH -o /fast/users/a1742674/outputs/SomaticVcalling/slurm-%j.out
#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --time=00:30:00
#SBATCH --mem=1GB

# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=a1742674@adelaide.edu.au

# load modules
module load Java/1.8.0_121
module load GATK
module load SAMtools

# run the executable
# A script to filter somatic variants called by gatk Mutect2, designed for the Phoenix supercomputer

usage()
{
echo "# A script to filter somatic variants called by gatk Mutect2, designed for the Phoenix supercomputer
# Requires: GATK and a list of samples
#
# Usage sbatch --array 0-(nSamples-1) $0  -v /path/to/vcf/files -S listofsamples.txt [-o /path/to/output] | [ - h | --help ]
#
# Options
# -S    REQUIRED. List of sample ID in a text file
# -v    REQUIRED. /path/to/vcf/files. Path to where you want to find your Mutect2 vcf files. Every file matching a sample ID will be used.
# -O    OPTIONAL. Path to where you want to find your file output (if not specified current directory is used)
# -h or --help  Prints this message.  Or if you got one of the options above wrong you'll be reading this too!
#
#
# Original: Derived from GATK.HC.Phoenix by Mark Corbett, 16/11/2017
# Modified: (Date; Name; Description)
# 21/06/2018; Mark Corbett; Modify for Haloplex
# 09/07/2018; Clare van Eyk; modify for use with Mutect2 command from GATK
# 13/08/2019; Clare van Eyk; modify to filter Mutect2 calls with FilterMutectCalls
"
}


# Define directories
InDir=/fast/users/a1742674/outputs/SomaticVcalling/Mutect2_2
vcfDir=$InDir/vcf
OutDir=$InDir/strictstrandbias
tmpDir=$InDir/tempdir

if [ -z $vcfDir ]; then # If no vcfDir name specified then do not proceed
        usage
        echo "#ERROR: You need to tell me where to find the vcf files."
        exit 1
fi

if [ ! -d $OutDir ]; then
        mkdir -p $OutDir
fi

if [ ! -d $tmpDir ]; then
        mkdir -p $tmpDir
fi

## Start of the script ##
###On each sample###

cd $vcfDir
QUERIES=($(ls *.vcf))

cd $vcfDir
gatk FilterMutectCalls \
-V $vcfDir/${QUERIES[$SLURM_ARRAY_TASK_ID]} \
--max-germline-posterior 0.1 \
--max-strand-artifact-probability 1.00 \
-O $OutDir/${QUERIES[$SLURM_ARRAY_TASK_ID]}.filtered.vcf >> $tmpDir/${QUERIES[$SLURM_ARRAY_TASK_ID]}.filter.pipeline.log 2>&1

module load BCFtools
bcftools view -O v -f PASS -i 'FORMAT/AF[0:0] < 0.4' $OutDir/${QUERIES[$SLURM_ARRAY_TASK_ID]}.filtered.vcf > $OutDir/${QUERIES[$SLURM_ARRAY_TASK_ID]}_PASS.vcf

#--max-germline-posterior 0.1 \
#--max-strand-artifact-probability 1.00 \
#--min-strand-artifact-allele-fraction 0.01 \
#V2038-1.dedup.realigned.recalibrated.bam.mosaic.PONs_gnomad.vcf
