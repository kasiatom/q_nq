#!/bin/bash

samples=$( ls *.bam  | sed 's/-.*//' | sort | uniq ) 

for sample in $samples
do

 macs3 hmmratac --cutoff-analysis-only --means 75 170 340 510 --stddevs 15 15 15 15 -i "$sample"-markdup-regions.bam --outdir $HOME/BAM-regions-do-HMMRATAC/HMMRATAC_output -n "$sample"
done

