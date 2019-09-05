# Whole Genome Sequencing (WGS) of disease discordant monozygotic twins (ddMZ) for Cerebral Palsy (CP)

This project is done as part of research year of Masters of Biotechnology (Biomedical Science) 

Samples:six families (affected twin, parents and unaffected twins)

## 1.0 Single Nucleotide Variant Findings
- 1.1 Variant Calls
- 1.2 Annotations using ANNOVAR

## 2.0 Structural Variant Findings
The pipeline to identify structural variants was executed similarly for all three variants that are obtained using three different variant callers (CNVnator, Delly and RetroSeq). The orders are as follows:-

## 2.1 Variant Calling
CNVnator and RetroSeq only requires a single script, whereas DELLY variant callers requires multiple scripts as along the variant calling process, these variants will be assessed and filtered thoroughly.

## 2.2 Post-Variant Calling

- In-house filtering: To eliminate variants that are frequently present in 24 samples according to SV type. Firstly, variants that commonly present in the population (all samples) was identified and combined, creating a minidatabase. This was done prior to using this information to eliminate common variants in each individual. Common variants are variants that present in more than eight individuals/more than two families.

- Variant Inheritance: To segregate variant according to inheritance patterns, whether it is only present in affected twin, or both twins and whether these variants are inherited or de novo. For CNVnator and RetroSeq-based variants, the variants are segregated according to the overlaps of the variant coordinates, whereas, genotypes information are used for Delly-based variants

- Variant Annotations: In order to obtain further information on the variants, AnnotSV (Geoffroy et al., 2018) was used.

- Hard-Filter:The variants are filtered based on prediction scores respective to type of SV

*The scripts attached are labeled with name of variant caller, and the order of the script. For variant calling steps, the scripts are labelled with 0 and post variant calling will be labeled as 1 and so on. Both CNVnator and RetroSeq-based variants undergo same post-variant caliing process, therefore only one of each script is attached here to avoid repetitions*

## 3.0 Somatic Variant Findings
- 3.1 Mutect2
- 3.2 MosaicHunter

## 4.0 Visualisation

## 5.0 References
