#!/bin/bash
# This script is to run HMMRATAC on the BAM files that have been filtered for regions of interest

# get file names
samples=$( ls *.bam  | sed 's/-.*//' | sort | uniq ) 

#echo 
#read -p '-u value: ' u
#read -p '-l value: ' l
#read -p '-c value: ' c

# run HMMRATAC on each sample
for sample in $samples
do

 macs3 hmmratac -l 4 -u 25 -c 1.2 --means 75 170 340 510 --stddevs 15 15 15 15 -i "$sample"-markdup-regions.bam --outdir $HOME/BAM-regions-do-HMMRATAC/HMMRATAC_output_l4u25c1.2 -n "$sample"
done

