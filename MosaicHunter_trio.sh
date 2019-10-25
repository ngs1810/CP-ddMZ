#!/bin/sh
#SBATCH -J MosaicHunter.trio
#SBATCH -o /fast/users/a1742674/outputs/SomaticVcalling/slurm-%j.out
#SBATCH -A robinson
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --time=15:00:00
#SBATCH --mem=8GB

# Notification configuration
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=a1742674@adelaide.edu.au

MHDIR=/fast/users/a1742674/outputs/SomaticVcalling/MosaicHunter
#BAMDIR=/data/neurogenetics/alignments/Illumina/genomes/R_180917_JEFCRA_DNA_M001
BAMDIR2=/data/neurogenetics/alignments/Illumina/genomes/R_180104_JEFCRA_DNA_M002
BAMDIR=/data/neurogenetics/alignments/Illumina/genomes/R_180104_JEFCRA_DNA_M001

OUTDIR=$MHDIR/outputs

if [ ! -d $OUTDIR ]; then
        mkdir -p $OUTDIR
fi 

cd $MHDIR/MosaicHunter

module load Java/1.8.0_121
module load BLAT

java -jar build/mosaichunter.jar -C conf/genome.properties \
-P reference_file=/data/biohub/Refs/human/gatk_bundle/2.8/b37/human_g1k_v37_decoy.fasta \
-P input_file=$BAMDIR/V4910-1.dedup.realigned.recalibrated.bam \
-P mosaic_filter.father_bam_file=$BAMDIR/V4910-2.dedup.realigned.recalibrated.bam \
-P mosaic_filter.mother_bam_file=$BAMDIR/V4910-3.dedup.realigned.recalibrated.bam \
-P mosaic_filter.sex=F \
-P mosaic_filter.mode=trio \
-P mosaic_filter.dbsnp_file=/data/neurogenetics/RefSeq/GATK/b37/dbsnp_138.b37.vcf \
-P repetitive_region_filter.bed_file=$MHDIR/MosaicHunter/resources/all_repeats.b37.bed \
-P common_site_filter.bed_file=$MHDIR/MosaicHunter/resources/WGS.error_prone.b37.bed \
-P ouput_dir=$OUTDIR
