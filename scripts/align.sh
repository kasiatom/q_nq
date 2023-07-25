#!/bin/bash

## all programs are in the conda bio environment
set -e -o  pipefail

## find all sample names (here for raw fastq, but should be for the trimmed ones - after fastp with -r)
samples=$( ls $HOME/ATAC_seq/fastqs/*gz | sed "s/-UJ.*//" |  sed 's|.*/||' | sort | uniq)


for sample in $samples
do
   ## for each sample find all fastq1 and save them as list separated with coma
   fastqs1=$(ls $HOME/ATAC_seq/fastqs/"$sample"-UJ*_R1_001.fastq.gz |  tr '\n' ',' | sed 's/,$//')
   ## prepare list of fastq2, important: keep the same order as in fastqs1
   fastqs2=$(echo $fastqs1 | sed 's|_R1_|_R2_|g')
   ## align reads, reference is in /mnt/qnap/users/kasia.tomala/genome; here symlinked as $HOME/genome
   bowtie2 --very-sensitive-local \
      -x $HOME/genome/R64-1-1 \  
      -1 $fastqs11 -2 $fastqs2 -S "$sample".sam \
      --rg-id "$sample" --rg "$sample" 2>"$sample"-alignment-stats.txt

   ## makr duplicates
   gatk MarkDuplicates \
      -I "$sample".sam \
      -O "$sample"-markdup-unsorted.bam \
      -M "$sample"-metrics.txt \
      --ASSUME_SORT_ORDER  queryname

   ##sort and index bam
   samtools sort "$sample"-markdup-unsorted.bam -@ 10 -o "$sample"-markdup.bam
   samtools index "$sample"-markdup.bam

   ## clean
   rm "$sample"-markdup-unsorted.bam "$sample".sam 

done 


