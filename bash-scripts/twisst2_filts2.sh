#!/bin/bash
#PBS -N twisst2_filts_eth
#PBS -l select=1:ncpus=1:mem=5gb:scratch_local=150gb
#PBS -l walltime=32:00:00
#PBS -e PBS/
#PBS -o PBS/

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }
#clean scratch after the end
trap 'clean_scratch' TERM EXIT

cd $SCRATCHDIR 

## paths
path=/storage/plzen1/home/repulles/my_modules/genomics_general
VCF_mel="$DATADIR/03.3.VCF_files/Allsamples_mel_var.vcf.gz"
VCF_eth="$DATADIR/03.3.VCF_files/Allsamples_eth_var.vcf.gz"
geno_mel="$DATADIR/12.Dstats/Allsamples_mel_var.geno.gz"
output=$DATADIR/11.Twisst2

## 2. Filter: min 50% of ind of each pop present, and max 75% of heteroz
python $path/filterGenotypes.py -i $geno_mel -o ${output}/Allsamples_mel.geno.gz --popsFile $DATADIR/08.pixy/Allsamples_mel.populations --minPopCalls 2 5 7 8 --maxHet 0.75 --minVarCount 2

## 3. Extract sites from vcf:
zcat ${output}/Allsamples_mel.geno.gz | cut -f1,2 | sed '1d' > keepmel.sites
zcat ${output}/Allsamples_eth.geno.gz | cut -f1,2 | sed '1d' > keepeth.sites

## 4. filter my .vcf file (I used my modified.vcf that I already had because I had filtered out sites were the outgrp was heterozygote)
module load bcftools 
bcftools view -R keepmel.sites $VCF_mel -Oz -o ${output}/Allsamples_mel_var_filt.50min.75maxHet.vcf.gz
bcftools view -R keepeth.sites $VCF_eth -Oz -o ${output}/Allsamples_eth_var_filt.50min.75maxHet.vcf.gz

## RUN TWISST2

## Modify .vcf file with sticcs (from twisst2). Twisst doesn't load if I have bcftools loaded (something incompatible)
module add mambaforge
mamba activate /auto/plzen1/home/repulles/my_modules/sticcs_env

wallacei1ID="/storage/brno12-cerit/home/repulles/03.Heliconius/03.2.RemovePCRduplicates_fastp/final.bam/ERR1143625.final.bam"
wallacei2ID="/storage/brno12-cerit/home/repulles/03.Heliconius/03.2.RemovePCRduplicates_fastp/final.bam/SRR3102341.final.bam"

sticcs prep -i ${VCF_eth} -o ${output}/Heliconius_nomelpomene_Optix.filt_modified.vcf.gz  --outgroup ${wallacei1ID} --outgroup ${wallacei2ID}
sticcs prep -i ${output}/Allsamples_mel_var_filt.50min.75maxHet.vcf.gz -o ${output}/Allsamples_mel_var_filt_modified.vcf.gz  --outgroup ${wallacei1ID} --outgroup ${wallacei2ID}
sticcs prep -i ${output}/Allsamples_eth_var_filt.50min.75maxHet.vcf.gz -o ${output}/Allsamples_eth_var_filt_modified.vcf.gz  --outgroup ${wallacei1ID} --outgroup ${wallacei2ID}

## Filters!
# I filtered out SNPs where the outgroup was missing or it was heterozigote! (at least for one ind from th outgrp, I have 2 ind)

# for noethilla and nomelpomene I used directly my vcf files because they are already filteres (50% ind per pop, 75 het...)

## Run tiwsst2
ttwisst2 sticcstack -i ${output}/Allsamples_mel_var_filt_modified.vcf.gz -o ${output}/output_bes.mel_300426/Variants_AllChr_bes.mel --max_subtrees 1000 --ploidy 2 --unrooted --output_topos ${output}/Variants_AllChr_bes.mel --group_names besckei numata nanna wallacei --groups_file $DATADIR/08.pixy/Allsamples_mel.populations
twisst2 sticcstack -i ${output}/Allsamples_eth_var_filt_modified.vcf.gz -o ${output}/output_bes.eth_300426/Variants_AllChr_bes.eth --max_subtrees 1000 --ploidy 2 --unrooted --output_topos ${output}/Variants_AllChr_bes.eth --group_names besckei numata narcaea wallacei --groups_file $DATADIR/08.pixy/Allsamples_eth.populations
