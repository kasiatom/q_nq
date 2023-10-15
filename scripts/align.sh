#!/bin/bash

## all programs are in the conda bio environment
set -e -o  pipefail


## create output directory - if not present
if [ ! -d $HOME/output ]
then
   mkdir $HOME/output
fi   

## find all sample names (here for raw fastq, but should be for the trimmed ones - after fastp with -r)
#samples=$( ls $HOME/ATAC_seq/fastqs/*gz | sed "s/-UJ.*//" |  sed 's|.*/||' | sort | uniq)
samples=127

for sample in $samples
do
   ## for each sample find all fastq1 and save them as list separated with coma
   fastqs1=$(ls $HOME/ATAC_seq/fastqs/"$sample"-UJ*_R1_001.fastq.gz |  tr '\n' ',' | sed 's/,$//')
   ## prepare list of fastq2, important: keep the same order as in fastqs1
   fastqs2=$(echo $fastqs1 | sed 's|_R1_|_R2_|g')
   ## align reads, reference is in /mnt/qnap/users/kasia.tomala/genome; here symlinked as $HOME/genome
   bowtie2 --very-sensitive-local \
      -x $HOME/genome/R64-1-1 \
      -1 $fastqs1 -2 $fastqs2 -S $HOME/output/"$sample".sam \
      --rg-id "$sample" --rg "$sample" 2>$HOME/output/"$sample"-alignment-stats.txt

   ## makr duplicates
   gatk MarkDuplicates \
      -I $HOME/output/"$sample".sam \
      -O $HOME/output/"$sample"-markdup-unsorted.bam \
      -M $HOME/output/"$sample"-metrics.txt \
      --ASSUME_SORT_ORDER  queryname

   ##sort and index bam
   samtools sort $HOME/output/"$sample"-markdup-unsorted.bam -@ 10 -o $HOME/output/"$sample"-markdup.bam
   samtools index $HOME/output/"$sample"-markdup.bam

   ## clean
   rm $HOME/output/"$sample"-markdup-unsorted.bam $HOME/output/"$sample".sam 

done 


