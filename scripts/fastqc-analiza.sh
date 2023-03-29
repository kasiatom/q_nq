#!/bin/bash

echo 
read -p 'gdzie znajdują się pliki?' odczyt
read -p 'gdzie zapisać pliki?' zapis


fastqc $odczyt/*fq.gz -O $zapis

echo gotowe!

