#!/bin/bash
#PBS -N Fst
#PBS -l select=1:ncpus=1:mem=5gb:scratch_local=100gb
#PBS -l walltime=05:00:00
#PBS -e PBS/
#PBS -o PBS/

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline

test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }
## clean scratch after the end
trap 'clean_scratch' TERM EXIT
cd $SCRATCHDIR

## files
cp $DATADIR/05.Allsamples_allsites_PCA_Treemix_Fst_pi/Allsamples_allsites_variants03.vcf.gz* .
VCF=Allsamples_allsites_variants03.vcf.gz
## spp file lists (list of spp samples in vcf file)
ethilla="$DATADIR/06.Fst/ethilla.list"
melpomene="$DATADIR/06.Fst/melpomene.list"
numata="$DATADIR/06.Fst/numata.list"
besckei="$DATADIR/06.Fst/besckei.list"

out="$DATADIR/05.Allsamples_allsites_PCA_Treemix_Fst_pi"

## Only variants file
module load bcftools
#bcftools view -v snps $VCF -Oz -o SNP_Allsamples_allsites.vcf.gz
#bcftools index -t SNP_Allsamples_allsites.vcf.gz
## run vcftools
module load vcftools

#vcftools --gzvcf $VCF --weir-fst-pop $besckei --weir-fst-pop $ethilla --out ${out}/Fst_besckei_ethilla
vcftools --gzvcf $VCF --weir-fst-pop $besckei --weir-fst-pop $melpomene  --out ${out}/Fst_besckei_melpomene
vcftools --gzvcf $VCF --weir-fst-pop $besckei --weir-fst-pop $numata  --out ${out}/Fst_besckei_numata

vcftools --gzvcf $VCF --weir-fst-pop $ethilla --weir-fst-pop $melpomene  --out ${out}/Fst_ethilla_melpomene
vcftools --gzvcf $VCF --weir-fst-pop $ethilla --weir-fst-pop $numata  --out ${out}/Fst_ethilla_numata

vcftools --gzvcf $VCF --weir-fst-pop $melpomene --weir-fst-pop $numata  --out ${out}/Fst_melpomene_numata
