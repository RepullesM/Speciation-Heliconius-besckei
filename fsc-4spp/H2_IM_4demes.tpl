//Number of population samples (demes)
4
//Population effective sizes (number of genes)
Nnum
Nbes
Neth
Nmel
//Samples sizes and samples age
14 0
18 0
50 0
20 0
//Growth rates
0
0
0
0
//Number of migration matrices
3
//Migration matrix 0: present-day IM mel<->eth AND bes<->num
0.00      MF01   0.00      0.00
MF10   0.00      0.00      0.00
0.00      0.00      0.00      MF23
0.00      0.00      MF32   0.00
//Migration matrix 1: post-TdivEM, NA_meleth (deme3) <-> bes (deme1) & NA_meleth (deme3) <-> num (deme0); mig bes<->num always on (IM)
0.00      MF01      0.00      MF03
MF10      0.00      0.00      MF13
0.00      0.00      0.00      0.00
MF30	MF31      0.00      0.00
//Migration matrix 2: all off after TdivBN
0.00      0.00      0.00      0.00
0.00      0.00      0.00      0.00
0.00      0.00      0.00      0.00
0.00      0.00      0.00      0.00
//historical event: time, source, sink, migrants, new size, new growth rate, migr. matrix
3 historical events
TdivEM 2 3 1 NAmeleth 0 1
TdivBN 0 1 1 NAbesnum 0 2
TdivALL 1 3 1 Nlca 0 2
//Number of independent loci [chromosome]
1 0
//Per chromosome: Number of linkage blocks
1
//per Block: data type, num loci, rec. rate and mut rate + optional parameters
FREQ 1 0 2.9e-9 OUTEXP
