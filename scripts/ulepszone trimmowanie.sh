#!/bin/bash

L1=$( find ~/test-trimmed/*R1_001.fastq.gz | awk -F'[/]' '{print $5}' )
L2=$( find ~/test-trimmed/*R2_001.fastq.gz | awk -F'[/]' '{print $5}' )

java -jar trimmomatic-0.39.jar PE ~/test-trimmed/$L1 ~/test-trimmed/$L2 ~/paired/$L1 ~/unpaired/$L1 ~/paired/$L2 ~/unpaired/$L2 ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True SLIDINGWINDOW:4:20 MINLEN:50

echo gotowe
