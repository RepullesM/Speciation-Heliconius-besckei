#!/bin/bash
#PBS -N Fsc2_composites_likelihood_IM
#PBS -l select=1:ncpus=1:mem=10gb:scratch_local=100gb
#PBS -l walltime=24:00:00
#PBS -e PBS/
#PBS -o PBS/
#PBS -J 1-3

DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/13.fsc2
trap 'clean_scratch' TERM EXIT

## Set spp pair to run with PBS_ARRAY_INDEX
spp=$(awk '{print $1}' $DATADIR/spp_pairs.txt | sed -n "${PBS_ARRAY_INDEX}p")

# Move to working directory
cd $SCRATCHDIR

# Best runs in the second (SC) and third (IM) column of the file "spp_pairs.txt"
SCENARIO=IM
RUN=$(awk '{print $3}' $DATADIR/spp_pairs.txt | sed -n "${PBS_ARRAY_INDEX}p")

input=$DATADIR/${spp}/${SCENARIO}_run${RUN}
out=$DATADIR/03.likelihood_distribution

# create temporary obs file with name _maxL_MSFS.obs (use your real data .obs file)
cp ${input}/${SCENARIO}_jointMAFpop1_0.obs ${SCENARIO}_maxL_jointMAFpop1_0.obs
cp ${input}/${SCENARIO}/${SCENARIO}_maxL.par .

# Run fastsimcoal 20 times (in reality better 100 times) to get the likelihood of the observed SFS under the best parameter values with 1 mio simulated SFS.
module load fastsimcoal2

for i in {1..100}
do
 fsc27093 -i ${SCENARIO}_maxL.par -n1000000 -m -q -0
 # Fastsimcoal will generate a new folder called ${SCENARIO}_maxL and write files in there

 # collect the lhood values (Note that >> appends to the file, whereas > would overwrite it)
 sed -n '2,3p' ${SCENARIO}_maxL/${SCENARIO}_maxL.lhoods  >> ${out}/${spp}_${SCENARIO}.lhoods

 # delete the folder with results
 rm -r ${SCENARIO}_maxL/
done

