#!/bin/bash

set -e -o pipefail




find  "$HOME/dominika/bams/" -name *bam  -exec basename \{} \; \
| sed 's/_bwa-markdup.bam//' \
| grep -v '^[ADEC][247]' 
| xargs -i -n 1 -P 10  bash -c \
    'gatk  --java-options "-Xmx24g" \
        HaplotypeCaller \
        -R  $HOME/genome/scer.fa \
        -I  $HOME/dominika/bams/{}_bwa-markdup.bam \
        -O $HOME/working/{}_hc.gvcf.gz \
        --pcr-indel-model AGGRESSIVE \-
        -dont-use-soft-clipped-bases \
        -ploidy 1 \
        -ERC GVCF'

GVCFS=$(ls $HOME/working/*_hc.gvcf.gz | sed 's/^/-V /')
gatk --java-options "-Xmx24g" \
    CombineGVCFs \
        -R $HOME/genome/scer.fa \
        $GVCFS \
        -O $HOME/working/q_nq.g.vcf.gz   

gatk --java-options "-Xmx44g" \
    GenotypeGVCFs \
        -R $HOME/genome/scer.fa \
        -V $HOME/working/q_nq.g.vcf.gz \
        -O  $HOME/working/q_nq.vcf.gz


