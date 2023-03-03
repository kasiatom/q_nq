#!/bin/bash

set -e -o pipefail

REF="$HOME/genome/scer.fa"

for i in $HOME/dominika/bams/[ACDE][0-9]*_bwa-markdup.bam
do
  ID=$(basename $i | sed 's/_bwa-markdup.bam//')
   echo Running Mutect for population $ID
   gatk --java-options "-Xmx24g" \
      Mutect2 \
         -R $REF \
         -I $i \
         -O $HOME/working/"$ID"_m2.vcf.gz \
         --genotype-germline-sites true \
         --f1r2-tar-gz $HOME/working/"$ID"_f1r2.tar.gz \
         --pcr-indel-model AGGRESSIVE \
         --dont-use-soft-clipped-bases
    
   echo Running LearnReadOrientationModel for population $ID
    gatk LearnReadOrientationModel \
         -I $HOME/working/"$ID"_f1r2.tar.gz \
         -O $HOME/working/"$ID"_artifact-priors.tar.gz
    
   echo Running filtering for population $ID 
   ## check whether the filtering parametes are ok (https://gatk.broadinstitute.org/hc/en-us/articles/360036856831-FilterMutectCalls),
   ## if not change or remove the line starting from --max-alt (to use defaults)
    gatk --java-options "-Xmx24g" \
       FilterMutectCalls \
       -V $HOME/working/"$ID"_m2.vcf.gz \
       -R $REF \
       -O $HOME/working/"$ID"_filtered-m2.vcf.gz  \
       --max-alt-allele-count 1 --max-events-in-region 2 --unique-alt-read-count 5 --min-allele-fraction 0.1 --min-reads-per-strand 2 \
       --ob-priors $HOME/working/"$ID"_artifact-priors.tar.gz \
       -stats $HOME/working/"$ID"_m2.vcf.gz.stats
  
  rm  $HOME/working/"$ID"_f1r2.tar.gz $HOME/working/"$ID"_artifact-priors.tar.gz
   
done
echo "All done" 