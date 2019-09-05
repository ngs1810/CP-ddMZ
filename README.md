# Whole Genome Sequencing (WGS) of disease discordant monozygotic twins (ddMZ) for Cerebral Palsy (CP)

This project is done as part of research year of Masters of Biotechnology (Biomedical Science) 

Samples:six families (affected twin, parents and unaffected twins)

## 1.0 Single Nucleotide Variant Findings
- 1.1 Variant Calls
- 1.2 Annotations using ANNOVAR

## 2.0 Structural Variant Findings
The pipeline to identify structural variants was executed similarly for all three variants that are obtained using three different variant callers (CNVnator, Delly and RetroSeq). The orders are as follows:-

*Variant Calling*

*In-house filtering*: To eliminate variants that are frequently present in 24 samples

*Variant Inheritance*: To segregate variant according to inheritance patterns, whether it is only present in affected twin, or both twins and whether these variants are inherited or de novo.

*Variant Annotations*: In order to obtain further information on the variants, AnnotSV (Geoffroy et al., 2018) was used.

*Hard-Filter*:The variants are filtered based on prediction scores respective to type of SV

The scripts attached are labeled with name of variant caller, and the order of the script.

## 3.0 Somatic Variant Findings
- 3.1 Mutect2
- 3.2 MosaicHunter
