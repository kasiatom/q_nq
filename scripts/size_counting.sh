#!/bin/bash 

## user input

echo
read -p 'gdzie znajdują się pliki?' odczyt
read -p 'gdzie zapisać pliki?' zapis

## find all sample names

samples=$( ls $odczyt/*.bam | sed 's|.*/||' | sed 's/-markdup-regions.bam//' | sort | uniq)

## count lenght of fragments and thier number

for sample in $samples
do
samtools view $odczyt/"$sample"*.bam | awk '$9>0' | cut -f 9 | sort | uniq -c | sort -b -k2,2n | sed -e 's/^[ \t]*//' > $zapis/"$sample"_length_count.txt
done