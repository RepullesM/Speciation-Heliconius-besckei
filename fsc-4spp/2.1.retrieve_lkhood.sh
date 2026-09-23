#!/bin/bash


## Retreiving results from all scenario and iterations for bes.eth
for PREFIX in H0_IM_4demes H1_IM_4demes H2_IM_4demes	H3_IM_4demes H4_IM_4demes H5_IM_4demes H6_IM_4demes
do 
	echo "run" `cat ${PREFIX}_Tdivconstrained/${PREFIX}_run3/${PREFIX}/${PREFIX}.bestlhoods | awk 'NR==1'` > 02.output_beslhood_constrained/results_${PREFIX}.txt
	for i in {1..100}
	do
		if test -f ${PREFIX}_Tdivconstrained/${PREFIX}_run${i}/${PREFIX}/${PREFIX}.bestlhoods
		then
			echo "$i" `cat ${PREFIX}_Tdivconstrained/${PREFIX}_run${i}/${PREFIX}/${PREFIX}.bestlhoods | awk 'NR==2'` >> 02.output_beslhood_constrained/results_${PREFIX}.txt
		fi
	done
done
