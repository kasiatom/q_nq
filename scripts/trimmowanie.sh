#!/bin/bash

echo 
read -p 'gdzie znajdują się pliki?' odczyt
read -p 'gdzie zapisać pliki sparowane?' pary
read -p 'gdzie zapisać pliki niesparowane?' niepary
read -p 'wartość minlen' minlen

conda activate fastqc

L1=$( find . -type f -path $odczyt -name '*R1_001.fastq.gz' )
L2=$( find . -type f -path $odczyt -name '*R2_001.fastq.gz' )

java -jar trimmomatic-0.39.jar PE $odczyt/$L1 $odczyt/$L2 $pary/$L1 $niepary/$L1 $pary/$L2 $niepary/$L2 ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True SLIDINGWINDOW:4:20 MINLEN:$minlen

 echo gotowe
