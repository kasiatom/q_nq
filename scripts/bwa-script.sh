#!/bin/bash
set -e -o pipefail


## align reads
REF="$HOME/genome/scer.fa"

for fq1 in $HOME/dominika/*_1.fq.gz
do

  fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/')
  ID=$(basename $fq1 | sed 's/_1.fq.gz//')
  echo mapuje $ID

  RG_ID="V350143589L3C001R001"
  RG_PU="$RG_ID"".""$ID"
  RG_LB="$ID"".library"
  RG_SM="$ID" 
  RG_PL="BGI" 

  bwa mem \
          -t 10 \
          -R "@RG\tID:""$RG_ID""\tPU:""$RG_PU""\tPL:""$RG_PL""\tLB:""$RG_LB""\tSM:""$RG_SM" \
          -K 100000000 -v 3 -Y  \
          $REF \
          "$fq1" "$fq2" \
          > $HOME/working/"$ID"_bwa-unsorted.sam


   ## mark duplicated reads
   echo zaznaczam duplikaty $ID
   gatk MarkDuplicates \
      -I $HOME/working/"$ID"_bwa-unsorted.sam \
      -O $HOME/working/"$ID"_bwa-markdup-unsorted.bam \
      -M $HOME/working/"$ID"_bwa-metrics.txt \
      --ASSUME_SORT_ORDER  queryname

   ## sort and index, write to qnap
   echo soruje 
   samtools sort $HOME/working/"$ID"_bwa-markdup-unsorted.bam -@ 10 -o $HOME/dominika/bams/"$ID"_bwa-markdup.bam
   samtools index $HOME/dominika/bams/"$ID"_bwa-markdup.bam

   ##clean
   rm $HOME/working/"$ID"_bwa-markdup-unsorted.bam $HOME/working/"$ID"_bwa-unsorted.sam 
done
echo swietna robota