#!/bin/bash

set -e -o pipefail

path="$HOME/working"

## normalize indels, split multiallelic, mark them previously
bcftools filter -i 'N_ALT > 1' $path/q_nq.vcf.gz -o $path/tmp1.vcf.gz -O z
tabix -p vcf $path/tmp1.vcf.gz

bcftools annotate $path/q_nq.vcf.gz --mark-sites MULTIALLELIC -a $path/tmp1.vcf.gz \
| bcftools norm -m -any \
| bcftools norm -f $HOME/genome/scer.fa -o $path/tmp2.vcf.gz -O z
tabix -p vcf $path/tmp2.vcf.gz

## annotate with VEP
vep --cache --offline --format vcf --vcf --force_overwrite \
    --dir_cache $HOME/vep_data/ \
    --input_file $path/tmp2.vcf.gz \
    --species saccharomyces_cerevisiae \
    --compress_output bgzip \
    --distance 200 \
    --no_intergenic \
    --force_overwrite \
    --output_file $path/tmp3.vcf.gz
  
tabix -p vcf $path/tmp3.vcf.gz
   
## pick VEP annotations into separate fields
bcftools +split-vep  \
    -c 'Gene,SYMBOL,IMPACT,Consequence,BIOTYPE,Protein_position,Amino_acids' \
    -p VEP_ \
    $path/tmp3.vcf.gz \
    -o  $path/tmp4.vcf.gz -O z

tabix -p vcf $path/tmp4.vcf.gz 
    
bcftools +split-vep  \
    -c 'Gene,SYMBOL,IMPACT,Consequence' \
    -p VEP_WORST_ \
    -s worst \
    $path/tmp4.vcf.gz \
    -o  $path/tmp5.vcf.gz -O z
     
tabix -p vcf $path/tmp5.vcf.gz

## filter variants according to GATK recommendations
#Filter SNP INDEL
#FS > 60 > 200
#ReadPosRankSum < -8.0 < -20.0
#QUAL < 30.0 < 30.0
#SOR > 3.0 NONE
#MQ < 40.0 NONE
#MQRankSum < -12.5 NONE
## remove variants with low genotyping rate (more than 2 strains with missing genotypes)
## remove variants present in any of the strains
printf "D0\nA0\nE0\n" > controls.txt
bcftools  filter -e 'TYPE="snp" & (INFO/FS > 60 | INFO/ReadPosRankSum < -8.0 | INFO/SOR > 3.0 | INFO/MQ < 40.0 | INFO/MQRankSum < -12.5)' $path/tmp5.vcf.gz \
    | bcftools filter -e 'TYPE="indel" & (INFO/FS > 200 | INFO/ReadPosRankSum < -20.0 )' \
    | bcftools filter -e 'QUAL<= 30.0 | INFO/MULTIALLELIC=1' \
    | bcftools filter -e 'COUNT(GT="mis") > 2' \
    | bcftools filter -e 'GT[@controls.txt]="alt"' -o $path/q_nq_filtered-annotated.vcf.gz -O z

tabix -p vcf $path/q_nq_filtered-annotated.vcf.gz
mv $path/tmp5.vcf.gz $path/q_nq_annotated.vcf.gz
mv $path/tmp5.vcf.gz.tbi $path/q_nq_annotated.vcf.gz.tbi

rm $path/tmp*vcf.gz*    