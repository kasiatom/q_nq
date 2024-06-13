#!/bin/bash
# This script is to run HMMRATAC on the BAM files that have been filtered for regions of interest

# get file names
samples=$( ls *.bam  | sed 's/-.*//' | sort | uniq ) 

#echo 
#read -p 'wartość -u: ' u
#read -p 'wartość -l: ' l
#read -p 'wartość -c: ' c

# run HMMRATAC on each sample
for sample in $samples
do

 macs3 hmmratac -l 8 -u 25 -c 3 --means 75 170 340 510 --stddevs 15 15 15 15 -i "$sample"-markdup-regions.bam --outdir $HOME/BAM-regions-do-HMMRATAC/HMMRATAC_output_l8u25c3 -n "$sample"
done

