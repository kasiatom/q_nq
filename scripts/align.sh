#!/bin/bash

## all programs are in the conda bio environment
set -e -o  pipefail

echo 
read -p 'gdzie znajdują się pliki?' odczyt

## create output directory - if not present
if [ ! -d $HOME/output ]
then
   mkdir $HOME/output
fi   

## find all sample names (here for raw fastq, but should be for the trimmed ones - after fastp with -r)
samples=$( ls $HOME/$odczyt/*gz | sed "s/-UJ.*//" |  sed 's|.*/||' | sort | uniq)
#samples=127

for sample in $samples
do
   ## for each sample find all fastq1 and save them as list separated with coma
   fastqs1=$(ls $HOME/$odczyt/"$sample"-UJ*_R1_001.fastq.gz |  tr '\n' ',' | sed 's/,$//')
   echo $fastqs1
   ## prepare list of fastq2, important: keep the same order as in fastqs1
   fastqs2=$(echo $fastqs1 | sed 's|_R1_|_R2_|g')
   echo $fastqs2
   ## align reads, reference is in /mnt/qnap/users/kasia.tomala/genome; here symlinked as $HOME/genome
   bowtie2 --very-sensitive-local \
      -x $HOME/genome/R64-1-1 \
      -1 $fastqs1 -2 $fastqs2 -S $HOME/output/"$sample".sam \
      --rg-id "$sample" --rg SM:"$sample" --rg PL:illumina 2>$HOME/output/"$sample"-alignment-stats.txt

   ## makr duplicates
   gatk MarkDuplicates \
      -I $HOME/output/"$sample".sam \
      -O $HOME/output/"$sample"-markdup-unsorted.bam \
      -M $HOME/output/"$sample"-metrics.txt \
      --ASSUME_SORT_ORDER  queryname

   ## -h (Include the header in the output); Skip alignments with MAPQ smaller than INT ([1] in our example) leave read mapped in proper pair and discard not primary alignment and supplementary alignment
   samtools view -h -f 2 -F 2304 $HOME/output/"$sample"-markdup-unsorted.bam -b -o $HOME/output/"$sample"-markdup-unsorted-fixed.bam

   ## sort and index bam
   samtools sort $HOME/output/"$sample"-markdup-unsorted-fixed.bam -@ 10 -o $HOME/output/"$sample"-markdup.bam
   samtools index $HOME/output/"$sample"-markdup.bam

   samtools view -q 1 $HOME/output/"$sample"-markdup.bam I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI -b -o $HOME/output/"$sample"-markdup-regions.bam


   ## clean
   rm $HOME/output/"$sample"-markdup-unsorted-fixed.bam $HOME/output/"$sample".sam 

done 


