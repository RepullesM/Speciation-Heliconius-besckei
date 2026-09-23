#!/bin/bash
#PBS -N FastimCoal2_H1_IM_4demes
#PBS -l select=1:ncpus=14:mem=1gb:scratch_local=10gb
#PBS -l walltime=124:00:00
#PBS -e PBS/
#PBS -o PBS/
#PBS -J 51-78:2

# Run ID
start=$((PBS_ARRAY_INDEX + 1))
end=$((PBS_ARRAY_INDEX + 2))


DATADIR=/storage/brno12-cerit/home/pavelmatos/fsc2_MAR
out=$DATADIR/H1_IM_4demes_Tdivconstrained

PREFIX="H1_IM_4demes"

file=$DATADIR/Allsamples_nowallacei_Allsites_GENOME_MSFS.obs

trap 'clean_scratch' TERM EXIT

# Move to working directory
cd $SCRATCHDIR

#run 5 times (for more, make array)
module load fastsimcoal2
for i in $(seq $start $end)
do
  if [ $i -gt 90 ]; then
    break
  fi
  mkdir ${PREFIX}_run$i
  cd ${PREFIX}_run$i
  cp ${DATADIR}/${PREFIX}.tpl .
  cp ${DATADIR}/${PREFIX}_Tdivconstrained.est ${PREFIX}.est
  cp ${file} ${PREFIX}_MSFS.obs
  fsc27093 -t ${PREFIX}.tpl -n 500000 -m -e ${PREFIX}.est -M -L 50 -q -c 14 --numBatches 16 --multiSFS 

  cd ..
  cp cp -r ${PREFIX}_run$i $out
done

cp -r ${PREFIX}_run* $out || export CLEAN_SCRATCH=false
