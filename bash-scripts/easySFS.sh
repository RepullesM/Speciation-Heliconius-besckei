#!/bin/bash
#PBS -N easySFS
#PBS -l select=1:ncpus=1:mem=500gb:scratch_local=500gb
#PBS -l walltime=05:00:00
#PBS -e PBS/
#PBS -o PBS/

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline

test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }
## clean scratch after the end
trap 'clean_scratch' TERM EXIT
cd $SCRATCHDIR

## Data and paths
out="/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/07.SFS_VCF"

cp /storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/03.3.VCF_files/All_sites_withoutChr21.vcf.gz* .
VCF="All_sites_withoutChr21.vcf.gz"

#cp /storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/03.3.VCF_files/Variants_withoutChr21.vcf.gz* .
#SNP="Variants_withoutChr21.vcf.gz"

cp ${out}/pop_list.txt .

## source to program
source /storage/plzen1/home/repulles/.bashrc
conda activate easySFS

## Resources
## For the preview I used: -l select=1:ncpus=1:mem=15gb:scratch_local=100gb and walltime=01:00:00

## estimate preview projections (I'll run preview only on snp data because of memory)
#easySFS.py -i $SNP -p pop_list.txt -f -a --preview

# Output goes to PBS/*.OU file
## Base on this, select best projection per pop (max num of ):
	# dadi manual recommends maximizing the number of segregating sites, 
	#but at the same time if you have lots of missing data then you might have to 
	#balance # of segregating sites against # of samples to avoid downsampling too far.


## Run easy SFS with selected projections
easySFS.py -i $VCF -p pop_list.txt -a -f --proj 14,42,12,14 -o easySFSout
cp -r easySFSout ${out}