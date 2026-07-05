#!/bin/bash
#PBS -N FastimCoal2_besckei-numata_SC
#PBS -l select=1:ncpus=6:mem=10gb:scratch_local=100gb
#PBS -l walltime=96:00:00
#PBS -e PBS/
#PBS -o PBS/
#PBS -J 0-99:20

# Run ID
start=$((PBS_ARRAY_INDEX + 1))
end=$((PBS_ARRAY_INDEX + 20))
# Scenario 
PREFIX=SC
DATADIR=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/13.fsc2
input=/storage/brno12-cerit/home/repulles/03.Heliconius/Kay_pipeline/07.SFS_VCF
out=$DATADIR/bes.num

file=$input/Allsamples_nowallacei_Allsites_GENOME_jointMAFpop1_0.obs

trap 'clean_scratch' TERM EXIT

# Move to working directory
cd $SCRATCHDIR

#run 5 times (for more, make array)
module load fastsimcoal2
for i in $(seq $start $end)
do
  if [ $i -gt 100 ]; then
    break
  fi
  mkdir ${PREFIX}_run$i
  cd ${PREFIX}_run$i
  cp ${out}/${PREFIX}.tpl ${out}/${PREFIX}.est .
  cp ${file} ${PREFIX}_jointMAFpop1_0.obs
  fsc27093 -t ${PREFIX}.tpl -n1000000 -m -e ${PREFIX}.est -M -L50 -q -c6
  cd ..
done

cp -r ${PREFIX}_run* $out || export CLEAN_SCRATCH=false
