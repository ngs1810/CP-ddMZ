# Whole Genome Sequencing (WGS) of disease discordant monozygotic twins (ddMZ) for Cerebral Palsy (CP)

This project is done as part of research year of Masters of Biotechnology (Biomedical Science) 

Samples: Six families (affected twin, parents and unaffected twin)

## 1.0 Single Nucleotide Variant Findings
- 1.1 Variant Calling using GATK (version 3.7-0-gcfedb67) (*GATKv3.x.HC.forGenomes.Local.sh*)
- 1.2 Annotations using ANNOVAR (*ANNOVARv3.SH*)
- 1.3 Inheritance pattern: to identify de novo, compound heterozygous, homozygous and X-linked variants (*TwinKeyMatching.sh*)

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

## 2.3 SV-Visualisation using SVPV 
- *SVPV.sh*

## 3.0 Somatic Variant Findings
- 3.1 To detect somatic variants through comparison between affected and unaffected twin in analogy of tumour and normal cells using Mutect2 *(Mutect_1.sh)*
- 3.2 Filter Mutect2 calls based on possibility of being germline and strand aftifacts  (*FilterMutect_2.sh*)
- 3.3 MosaicHunter *(MosaicHunter_paired.sh* *MosaicHunter_trio.sh)*
- 3.4 Annotating Mutect2 calls (*ANNOVARv3.sh*)

## 4.0 References
- Geoffroy V, Herenger Y, Kress A, Stoetzel C, Piton A, Dollfus H, Muller J.;AnnotSV: An integrated tool for Structural Variations annotation.Bioinformatics. 2018 Apr 14. doi: 10.1093/bioinformatics/bty304
- Jacob E. Munro, Sally L. Dunwoodie, Eleni Giannoulatou; SVPV: a structural variant prediction viewer for paired-end sequencing datasets. Bioinformatics 2017; 33 (13): 2032-2033. doi: 10.1093/bioinformatics/btx117
- Abyzov A, Urban AE, Snyder M, Gerstein M.CNVnator: an approach to discover, genotype, and characterize typical and atypical CNVs from family and population genome sequencing.Genome Res. 2011 Jun;21(6):974-84. doi: 10.1101/gr.114876.110.
- Tobias Rausch, Thomas Zichner, Andreas Schlattl, Adrian M. Stuetz, Vladimir Benes, Jan O. Korbel.
Delly: structural variant discovery by integrated paired-end and split-read analysis.
Bioinformatics 2012 28: i333-i339.
- Mutect2:https://software.broadinstitute.org/gatk/documentation/tooldocs/3.6-0/org_broadinstitute_gatk_tools_walkers_cancer_m2_MuTect2.php
- Huang, A.Y., Zhang, Z., Ye, A.Y., Dou, Y., Yan, L., Yang, X., Zhang, Y., and Wei, L. (2017) MosaicHunter: accurate detection of postzygotic single-nucleotide mosaicism through next-generation sequencing of unpaired, trio, and paired samples. Nucleic Acids Res 45, e76.
