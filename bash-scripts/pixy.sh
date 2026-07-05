#!/bin/bash
#PBS -N pixy
#PBS -l select=1:ncpus=6:mem=50gb:scratch_local=100gb
#PBS -l walltime=48:00:00
#PBS -e PBS/
#PBS -o PBS/

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline

test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }
## clean scratch after the end
trap 'clean_scratch' TERM EXIT
cd $SCRATCHDIR

### Run pixy for pi and dxy 

## load pixy
source /storage/plzen1/home/repulles/.bashrc
conda activate pixy

## files
#cp $DATADIR/00.Zhang2016/03.VCF/Zhang_chr18_chr15_WithoutEthilla.recode.vcf.gz* .
cp $DATADIR/03.3.VCF_files/Allsamples_Allsites.vcf.gz* .
VCF=Allsamples_Allsites.vcf.gz
out="$DATADIR/08.pixy"

## 10kb w
pixy --stats fst tajima_d pi dxy watterson_theta \
--vcf $VCF \
--populations $DATADIR/08.pixy/Allsamples_Allsites.populations \
--window_size 10000 \
--n_cores 6 \
--output_prefix Allsamples_Allsites --output_folder $out


### Genome wide calculations
## pi
#		awk 'NR>1{
#		    diffs[$1]+=$7
#		    comps[$1]+=$8
#		}
#		END{
#		    for(pop in diffs)
#		        print pop, diffs[pop]/comps[pop]
#		}' Allsamples_Allsites_pi.txt
#
## Theta W
#awk 'NR>1 {
#    raw[$1]+=$7;
#    sites[$1]+=$6
#}
#END {
#    for (pop in raw)
#        print pop, raw[pop]/sites[pop]
#}' Allsamples_Allsites_watterson_theta.txt


## Tajima's D and Fst can not be done that easy --> look pixy manual
