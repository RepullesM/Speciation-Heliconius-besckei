#!/bin/bash
#PBS -N ABBA-BABA
#PBS -l select=1:ncpus=4:mem=5gb:scratch_local=50gb
#PBS -l walltime=24:00:00
#PBS -e PBS/
#PBS -o PBS/

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }
#clean scratch after the end
trap 'clean_scratch' TERM EXIT

cd $SCRATCHDIR 

output="$DATADIR/12.Dstats"
#VCF="$DATADIR/09.SNP_ougrp/Variants_AllChr.vcf.gz"
VCF_eth="$DATADIR/03.3.VCF_files/Allsamples_eth_var.vcf.gz"
VCF_mel="$DATADIR/03.3.VCF_files/Allsamples_mel_var.vcf.gz"

pop_ethilla="$DATADIR/08.pixy/Allsamples_eth.populations"
pop_melpomene="$DATADIR/08.pixy/Allsamples_mel.populations"

## path to program
path=/storage/plzen1/home/repulles/my_modules/genomics_general

## Convert vcf to geno format
python $path/VCF_processing/parseVCFs.py -i ${VCF_eth} --threads 4 -o ${output}/Allsamples_eth_var.geno.gz
python $path/VCF_processing/parseVCFs.py -i ${VCF_mel} --threads 4 -o ${output}/Allsamples_mel_var.geno.gz

## D stats (ABBA-BABA). Done with '-w 5000', '-w 10000' and '-w 50000'
## ethilla
python $path/ABBABABAwindows.py -g ${output}/Allsamples_eth_var.geno.gz -f phased -o ${output}/D_Allsamples_eth_var_5kb.csv.gz \
	-w 5000 -m 5 -s 1000 -P1 numata -P2 besckei -P3 narcaea -O wallacei \
	-T 2 --minData 0.5 --popsFile ${pop_ethilla} --writeFailedWindows

## melpomene
python $path/ABBABABAwindows.py -g ${output}/Allsamples_mel_var.geno.gz -f phased -o ${output}/D_Allsamples_mel_var_5kb.csv.gz \
	-w 5000 -m 5 -s 1000 -P1 numata -P2 besckei -P3 nanna -O wallacei \
	-T 2 --minData 0.5 --popsFile ${pop_melpomene} --writeFailedWindows
