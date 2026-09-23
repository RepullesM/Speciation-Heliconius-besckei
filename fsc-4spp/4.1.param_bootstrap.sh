#!/bin/bash
#PBS -N Bootstp_H6_IM_4demes_Tconstrained
#PBS -l select=1:ncpus=1:mem=10gb:scratch_local=50gb
#PBS -l walltime=02:00:00
#PBS -e PBS/
#PBS -o PBS/


# Input/output directory
DATADIR=/storage/brno12-cerit/home/pavelmatos/fsc2_MAR
trap 'clean_scratch' TERM EXIT

# Move to working directory
cd $SCRATCHDIR

###############
## H2
###############
# Have to find the .par file of the best run using R treatment of the results
PREFIX=H6_IM_4demes
RUN=12

# 
input=$DATADIR/${PREFIX}_Tdivconstrained/${PREFIX}_run${RUN}

out=$DATADIR/04.bootstrap_Tdivconstrained_2

# Creates a sub-directory
mkdir ${PREFIX}
cd ${PREFIX}

# Copy files to my SCRATCHDIR
cp ${input}/${PREFIX}/${PREFIX}_maxL.par ${PREFIX}.par
cp ${input}/${PREFIX}/${PREFIX}.pv .
cp ${input}/${PREFIX}.tpl .
cp ${input}/${PREFIX}.est .


# Have to change a bit the ${SCENARIO}_maxL.par file to do simulations (here, Thibaut is using the .par file, not maxL.par, not sure why. In manual: This file needs to be modified to generate DNA sequence data (here 200,000 non-recombining segments of 100 bp) as)
sed -i 's/^1 0$/200000 0/g' ${PREFIX}.par 
sed -i 's/^FREQ 1/DNA 100/g' ${PREFIX}.par

# Then generate 50 SFS 
module load fastsimcoal2
fsc27093 -i ${PREFIX}.par -n50 -j -m -s0 -x -I -q -c1 --multiSFS
### Copy output
cp -r ../${PREFIX} ${out}/ || export CLEAN_SCRATCH=false
