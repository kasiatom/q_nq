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

mkdir $path/out
bcftools isec -C $path/q_nq_annotated.vcf.gz $path/q_nq_filtered-annotated.vcf.gz -p out
bgzip -c $path/out/0000.vcf > $path/q_nq_removed-annotated.vcf.gz 
tabix -p vcf $path/q_nq_removed-annotated.vcf.gz 
rm -r $path/out

## make table
paste \
<(printf "CHROM\tPOS\tREF\tALT\tQUAL\tVEP_Genes\tVEP_SYMBOLs\tVEP_IMPACTs\tVEP_Consequences\tVEP_BIOTYPEs\tVEP_Protein_positions\tVEP_Amino_acids\tVEP_WORST_Gene\tVEP_WORST_SYMBOL\tVEP_WORST_IMPACT\tVEP_WORST_Consequence") \
<(bcftools view -h $path/q_nq_filtered-annotated.vcf.gz | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_GT/') \
<(bcftools view -h $path/q_nq_filtered-annotated.vcf.gz | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $path/q_nq_filtered-annotated.vcf.gz | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $path/header

bcftools query -f "%CHROM\t%POS\t%REF\t%QUAL\t%INFO/VEP_Gene\t%INFO/VEP_SYMBOL\t%INFO/VEP_IMPACT\t%INFO/VEP_Consequence\t%INFO/VEP_BIOTYPE\t%INFO/VEP_Protein_position\t%INFO/VEP_Amino_acids\t%INFO/VEP_WORST_Gene\t%INFO/VEP_WORST_SYMBOL\t%INFO/VEP_WORST_IMPACT\t%INFO/VEP_WORST_Consequence[\t%GT][\t%DP][\t%AD]\n" $path/q_nq_filtered-annotated.vcf.gz \
> $path/tmp.tsv
cat $path/header $path/tmp.tsv > $path/q_nq.tsv

rm $path/header $path/tmp.tsv
cp $path/q_nq.tsv 