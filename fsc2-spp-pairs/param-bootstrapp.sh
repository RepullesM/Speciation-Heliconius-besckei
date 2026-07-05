#!/bin/bash
#PBS -N Fsc2_bootstp_input_bes.eth
#PBS -l select=1:ncpus=1:mem=10gb:scratch_local=50gb
#PBS -l walltime=02:00:00
#PBS -e PBS/
#PBS -o PBS/


# Input/output directory
DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/13.fsc2
trap 'clean_scratch' TERM EXIT

# Move to working directory
cd $SCRATCHDIR

###############
## SC
###############
# Have to find the .par file of the best run using R treatment of the results
spp=eth
SCENARIO=SC
RUN=78

# 
input=$DATADIR/bes.${spp}/${SCENARIO}_run${RUN}

out=$DATADIR/04.bootstrap

# Creates a sub-directory
mkdir bes.${spp}_${SCENARIO}
cd bes.${spp}_${SCENARIO}

# Copy files to my SCRATCHDIR
cp ${input}/${SCENARIO}/${SCENARIO}_maxL.par ${SCENARIO}.par
cp ${input}/${SCENARIO}/${SCENARIO}.pv .
cp ${input}/${SCENARIO}.tpl .
cp ${input}/${SCENARIO}.est .


# Have to change a bit the ${SCENARIO}_maxL.par file to do simulations (here, Thibaut is using the .par file, not maxL.par, not sure why. In manual: This file needs to be modified to generate DNA sequence data (here 200,000 non-recombining segments of 100 bp) as)
sed -i 's/^1 0$/720000 0/g'  ${SCENARIO}.par #here it changes the number of independent loci simulated in each replicate dataset.
sed -i 's/^FREQ 1/DNA 100/g'  ${SCENARIO}.par # Also change this part (I do it manually)

# Then generate 100 SFS 
module load fastsimcoal2
fsc27093 -i ${SCENARIO}.par -n100 -j -m -s0 -x -I -q -c1

### Copy output
cp -r ../bes.${spp}_${SCENARIO} ${out}/ || export CLEAN_SCRATCH=false

###############
## IM
###############

# Have to find the .par file of the best run using R treatment of the results
spp=eth
SCENARIO=IM
RUN=26

# 
input=$DATADIR/bes.${spp}/${SCENARIO}_run${RUN}

out=$DATADIR/04.bootstrap

# Creates a sub-directory
mkdir bes.${spp}_${SCENARIO}
cd bes.${spp}_${SCENARIO}

# Copy files to my SCRATCHDIR
cp ${input}/${SCENARIO}/${SCENARIO}_maxL.par ${SCENARIO}.par
cp ${input}/${SCENARIO}/${SCENARIO}.pv .
cp ${input}/${SCENARIO}.tpl .
cp ${input}/${SCENARIO}.est .


# Have to change a bit the ${SCENARIO}_maxL.par file to do simulations (here, Thibaut is using the .par file, not maxL.par, not sure why. In manual: This file needs to be modified to generate DNA sequence data (here 200,000 non-recombining segments of 100 bp) as)
sed -i 's/^1 0$/720000 0/g'  ${SCENARIO}.par #here it changes the number of simulation in each independet loci
sed -i 's/^FREQ 1/DNA 100/g'  ${SCENARIO}.par # Also change this part (I do it manually)

# Then generate 100 SFS 
module load fastsimcoal2
fsc27093 -i ${SCENARIO}.par -n100 -j -m -s0 -x -I -q -c1

### Copy output
cp -r ../bes.${spp}_${SCENARIO} ${out}/ || export CLEAN_SCRATCH=false

########################### Do it separately in an array!! ######################
# Running the optimization with each bootstraped SFS
#for i in {17..100}
#do
#	cp ${SCENARIO}.tpl ./${SCENARIO}/${SCENARIO}_$i/${SCENARIO}.tpl
#	cp ${SCENARIO}.est ./${SCENARIO}/${SCENARIO}_$i/${SCENARIO}.est
#	cp ${SCENARIO}.pv ./${SCENARIO}/${SCENARIO}_$i/${SCENARIO}.pv
#	cd ./${SCENARIO}/${SCENARIO}_$i/
#	~/TOOLS/fsc2705 -t ${SCENARIO}.tpl -e ${SCENARIO}.est -n1000000 -d -M -L50 --initValues ${SCENARIO}.pv -c10 -q
#	cd ${DIR}/bootstrap/
#done
##################################################################################

# Estimating confidence intervals
#cat ./${SCENARIO}/${SCENARIO}_1/${SCENARIO}/${SCENARIO}.bestlhoods | awk 'NR==1' > Parameters_bootstrap.txt
#for i in {1..16}
#do
#	cat ./${SCENARIO}/${SCENARIO}_$i/${SCENARIO}/${SCENARIO}.bestlhoods | awk 'NR==2' >> Parameters_bootstrap.txt
#done

