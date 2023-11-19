#!/bin/bash

## find all sample names
samples=$( ls $HOME/flagstat-fastp-r-g/*-markdup-regions.bam | sed 's|.*/||' | sed 's/-markdup-regions.bam//' | sort | uniq)

## run flagstat for each sample
for sample in $samples
do
   samtools flagstat $HOME/flagstat-fastp-r-g/"$sample"-markdup-regions.bam > $HOME/flagstat-fastp-r-g/"$sample"-flagstat.tsv
done
