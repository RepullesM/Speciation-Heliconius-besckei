#!/bin/bash
#PBS -N FastimCoal2_H3_IM_4demes
#PBS -l select=1:ncpus=20:mem=2gb:scratch_local=20gb
#PBS -l walltime=120:00:00
#PBS -e PBS/
#PBS -o PBS/
#PBS -J 0-50:2

# Run ID
start=$((PBS_ARRAY_INDEX + 1))
end=$((PBS_ARRAY_INDEX + 2))


DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/15.fsc2_4spp
input=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/07.SFS_VCF

PREFIX="H3_IM_4demes"
out=$DATADIR/$PREFIX

file=$input/Allsamples_nowallacei_Allsites_GENOME_MSFS.obs

trap 'clean_scratch' TERM EXIT

# Move to working directory
cd $SCRATCHDIR

#run 5 times (for more, make array)
module load fastsimcoal2
for i in $(seq $start $end)
do
  if [ $i -gt 50 ]; then
    break
  fi
  mkdir ${PREFIX}_run$i
  cd ${PREFIX}_run$i
  cp ${DATADIR}/${PREFIX}.tpl ${DATADIR}/${PREFIX}.est .
  cp ${file} ${PREFIX}_MSFS.obs
  fsc27093 -t ${PREFIX}.tpl -n 500000 -m -e ${PREFIX}.est -M -L 50 -q -c 20 --numBatches 20 --multiSFS 
  cd ..
  cp cp -r ${PREFIX}_run$i $out
done

cp -r ${PREFIX}_run* $out || export CLEAN_SCRATCH=false
