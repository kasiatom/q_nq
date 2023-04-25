#!/bin/bash

set -e -o pipefail
length=50  ## or 36

## find list of all fastq1 files
L1=$( find $HOME/test-trimmed/*R1_001.fastq.gz | awk -F'[/]' '{print $5}' )

for item in $L1
# item == full path to ONE fastq1 file
do
    
    FQ2=$(basename $item | sed 's/R1_/R2_/') ## one fastq2
    FQ1=$(basename $item)                    ## one fastq1 
    java -jar trimmomatic-0.39.jar PE \
        $HOME/test-trimmed/$FQ1 \
        $HOME/test-trimmed/$FQ2 \
        $HOME/paired/$FQ1 \
        $HOME/unpaired/$FQ1 \
        $HOME/paired/$FQ2 \
        $HOME/unpaired/$FQ2 \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True \
        SLIDINGWINDOW:4:20 \
        MINLEN:$length
done        

echo gotowe
