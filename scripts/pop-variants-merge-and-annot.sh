#!/bin/bash

set -e -o pipefail

## BEFORE RUNNING THIS SCRIPT DO THE FOLLOWING
## 1. conda create --name vep
## 2. conda activate vep
## 3. conda install -c bioconda ensembl-vep
## 4. conda deactivate
## Next steps should be performed in the terminal where you want to run the script (in screen, if you want to use screen)
## 5. conda activate bio
## 6. conda activate --stack vep
## 7. cd q_nq;git pull;cd ..
## 8. q_nq/scripts/pop-variants-merge-and-annot.sh &>$path/anno.log 

path=$HOME/working
REF=$HOME/genome/scer.fa

## fix Mutect2 bug
for i in $path/*_filtered-m2.vcf.gz
do
    ID=$(basename $i | sed 's/_filtered-m2.vcf.gz//')
    zcat $i | sed 's/##INFO=<ID=AS_FilterStatus,Number=A/##INFO=<ID=AS_FilterStatus,Number=./' | bgzip > $path/"$ID"_tmp.vcf.gz
    tabix -p vcf $path/"$ID"_tmp.vcf.gz

done    

## merge vcfs, split multiallelic sites, normalize variants
VCFS=$path/*_tmp.vcf.gz
bcftools merge $VCFS \
    | bcftools norm -m -any \
    | bcftools norm -f $REF \
    -o $path/q_nq_merged-norm.vcf.gz -O z
tabix -p vcf $path/q_nq_merged-norm.vcf.gz

## annotate with VEP
vep --cache --offline --format vcf --vcf --force_overwrite \
    --dir_cache $HOME/vep_data/ \
    --input_file $path/q_nq_merged-norm.vcf.gz \
    --species saccharomyces_cerevisiae \
    --compress_output bgzip \
    --distance 200 \
    --no_intergenic \
    --force_overwrite \
    --output_file $path/tmp2.vcf.gz
  
tabix -p vcf $path/tmp2.vcf.gz
   
## pick VEP annotations into separate fields
bcftools +split-vep  \
    -c 'Gene,SYMBOL,IMPACT,Consequence,BIOTYPE,Protein_position,Amino_acids' \
    -p VEP_ \
    $path/tmp2.vcf.gz \
    -o  $path/tmp3.vcf.gz -O z

tabix -p vcf $path/tmp3.vcf.gz 
    
bcftools +split-vep  \
    -c 'Gene,SYMBOL,IMPACT,Consequence' \
    -p VEP_WORST_ \
    -s worst \
    $path/tmp3.vcf.gz \
    -o  $path/q_nq_pop-annotated.vcf.gz -O z
     
tabix -p vcf $path/q_nq_pop-annotated.vcf.gz

## make table
paste \
<(printf "CHROM\tPOS\tREF\tALT\tFILTER\tVEP_Genes\tVEP_SYMBOLs\tVEP_IMPACTs\tVEP_Consequences\tVEP_BIOTYPEs\tVEP_Protein_positions\tVEP_Amino_acids\tVEP_WORST_Gene\tVEP_WORST_SYMBOL\tVEP_WORST_IMPACT\tVEP_WORST_Consequence\n") \
<(bcftools view -h $path/q_nq_filtered-annotated.vcf.gz | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_AF/') \
<(bcftools view -h $path/q_nq_filtered-annotated.vcf.gz | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $path/q_nq_filtered-annotated.vcf.gz | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $path/header

bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t%INFO/VEP_Gene\t%INFO/VEP_SYMBOL\t%INFO/VEP_IMPACT\t%INFO/VEP_Consequence\t%INFO/VEP_BIOTYPE\t%INFO/VEP_Protein_position\t%INFO/VEP_Amino_acids\t%INFO/VEP_WORST_Gene\t%INFO/VEP_WORST_SYMBOL\t%INFO/VEP_WORST_IMPACT\t%INFO/VEP_WORST_Consequence[\t%AF][\t%DP][\t%AD]\n" $path/q_nq_pop-annotated.vcf.gz \
| sed 's/,/;/g' > $path/tmp.tsv
cat $path/header $path/tmp.tsv > $path/q_nq_pop.tsv

rm $path/*tmp*


