#!/bin/bash

echo 
read -p 'gdzie znajdują się pliki?' odczyt
read -p 'gdzie zapisać pliki?' zapis
read -p 'nazwa pliku wynikowego' nazwa

conda activate fastqc

rm wyniki/multiqc_data/m*

rmdir wyniki/multiqc_data

multiqc $odczyt -o $zapis

rename 's/multiqc_report/'$nazwa'/' $zapis/multiqc_report.html
