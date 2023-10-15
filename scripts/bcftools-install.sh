#!/bin/bash
cd
wget https://github.com/samtools/bcftools/releases/download/1.18/bcftools-1.18.tar.bz2
tar -xvf bcftools-1.18.tar.bz2
cd bcftools-1.18
./configure --prefix=$HOME/bcftools-1.18/
make
mkdir -p $HOME/bcftools-1.18/libexec/bcftools/ 
cp $HOME/bcftools-1.18/plugins/* $HOME/bcftools-1.18/libexec/bcftools/

printf 'export PATH="$HOME/bcftools-1.18:$PATH"\n' >> $HOME/.bashrc
source $HOME/.bashrc
