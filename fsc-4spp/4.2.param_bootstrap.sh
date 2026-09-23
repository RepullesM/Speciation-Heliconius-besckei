#!/bin/bash
#PBS -N Fsc2_Bootstp_H6_IM_4demes_Tconstrained
#PBS -l select=1:ncpus=8:mem=2gb:scratch_local=100gb
#PBS -l walltime=48:00:00
#PBS -e PBS/
#PBS -o PBS/
#PBS -J 0-50:2

# Run ID
start=$((PBS_ARRAY_INDEX + 1))
end=$((PBS_ARRAY_INDEX + 2))


# Input/output directory
DATADIR=/storage/brno12-cerit/home/pavelmatos/fsc2_MAR
trap 'clean_scratch' TERM EXIT

# Move to working directory
cd $SCRATCHDIR

# Have to find the .par file of the best run using R treatment of the results
PREFIX=H6_IM_4demes
RUN=12

out=$DATADIR/04.bootstrap_Tdivconstrained/${PREFIX}


cp -r $out .
cd ${PREFIX}/

# Run
module load fastsimcoal2
for i in $(seq $start $end)
do
  if [ $i -gt 100 ]; then
    break
  fi
  cp ${PREFIX}.tpl ${PREFIX}/${PREFIX}_$i/${PREFIX}.tpl
  cp ${PREFIX}.est ${PREFIX}/${PREFIX}_$i/${PREFIX}.est
  cp ${PREFIX}.pv ${PREFIX}/${PREFIX}_$i/${PREFIX}.pv

  cd ${PREFIX}/${PREFIX}_$i/

  fsc27093 -t ${PREFIX}.tpl -e ${PREFIX}.est -n 500000 -m -M -L50 -q --initValues ${PREFIX}.pv -c 8 --numBatches 8 --multiSFS 


  cp -r ../${PREFIX}_$i* $out/${PREFIX}/
  cd ../../

done
