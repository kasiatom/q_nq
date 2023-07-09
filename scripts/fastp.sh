#!/bin/bash

## find list of all fastq1 files
L1=$( find $HOME/fastqs/*R1_001.fastq.gz | awk -F'[/]' '{print $5}' )

for item in $L1
# item == full path to ONE fastq1 file
 do 

    FQ2=$(basename $item | sed 's/R1_/R2_/') ## one fastq2
    FQ1=$(basename $item)                    ## one fastq1 
./fastp -g -r -i fastqs/$FQ1 -I fastqs/$FQ2 -o /home/mikolaj.radosz/fastp-r-g/$FQ1 -O /home/mikolaj.radosz/fastp-r-g/$FQ2

 done 

echo gotowe 
