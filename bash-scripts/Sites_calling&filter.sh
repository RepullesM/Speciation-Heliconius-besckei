#!/bin/bash
#PBS -N SNPcalling
#PBS -l select=2:ncpus=1:mem=40gb:scratch_local=150gb
#PBS -l walltime=48:00:00
#PBS -e PBS/
#PBS -o PBS/
#PBS -J 1-21

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline

## if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }
## clean scratch after the end
trap 'clean_scratch' TERM EXIT
cd $SCRATCHDIR || exit 1

## Set scaffold to run with PBS_ARRAY_INDEX
chr_file="$DATADIR/bigScaffolds.txt"
chr=$(cat $chr_file | sed -n "${PBS_ARRAY_INDEX}p")

## cp ref genome to scratchdir
cp /storage/brno12-cerit/home/repulles/03.Heliconius/02.1.fastqMapping/00.Hmel2.5_lepbase/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.* .

## reference genome
ref="Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa"
repeats="/storage/brno12-cerit/home/repulles/03.Heliconius/02.1.fastqMapping/00.Hmel2.5_lepbase_repeats/repeats_all.bed"

## modules
module load bcftools

## SNP calling with BCFtools. Allsites calling
bcftools mpileup -Ou -f ${ref} -b $DATADIR/Allsamples_nowallacei_bam.list -r ${chr} --threads 2 -q 20 -a DP,SP | bcftools call --threads 2 -m -Oz -a GQ,GP -o Allsamples_nowallacei_${chr}.vcf.gz

###########
# Vcf filtering Invariants
module load vcftools

vcftools --gzvcf Allsamples_nowallacei_${chr}.vcf.gz \
	--minGQ 20 \
	--minDP 4 --maxDP 100 \
	--exclude-bed ${repeats} \
	--remove-indels --max-alleles 2 \
	--max-maf 0 --max-missing 0.9 \
	--recode --recode-INFO-all \
	--out Allsamples_nowallacei_inv_${chr}

bcftools view -O z -o Allsamples_nowallacei_inv_${chr}_PASS.vcf.gz Allsamples_nowallacei_inv_${chr}.recode.vcf
bcftools index -t Allsamples_nowallacei_inv_${chr}_PASS.vcf.gz

# Vcf filtering Only Variants
vcftools --gzvcf Allsamples_nowallacei_${chr}.vcf.gz \
	--minGQ 20 \
	--minDP 4 --maxDP 100 \
	--exclude-bed ${repeats} \
	--remove-indels --max-alleles 2 \
	--min-alleles 2 --maf 0.03 --max-missing 0.9 \
	--recode --recode-INFO-all \
	--out Allsamples_nowallacei_var_${chr}

bcftools view -O z -o Allsamples_nowallacei_var_${chr}_PASS.vcf.gz Allsamples_nowallacei_var_${chr}.recode.vcf
bcftools index -t Allsamples_nowallacei_var_${chr}_PASS.vcf.gz

## Concat All_sites
bcftools concat --allow-overlaps \
Allsamples_nowallacei_var_${chr}_PASS.vcf.gz Allsamples_nowallacei_inv_${chr}_PASS.vcf.gz \
-O z -o $DATADIR/03.2.AllsitesVCF/Allsamples_nowallacei_Allsites_${chr}.vcf.gz

bcftools index -t $DATADIR/03.2.AllsitesVCF/Allsamples_nowallacei_Allsites_${chr}.vcf.gz

