#!/bin/bash
#OUT="multiSFS_20Chr"
#mkdir -p "$OUT"

files=(easySFS_June2026_noWallacei/easySFS_Hmel*/fastsimcoal2/Allsamples_nowallacei_Allsites_*_MSFS.obs)

[ -e "${files[0]}" ] || { echo "No MSFS files found"; exit 1; }

awk '
FNR==1 {
    if (NR==1) h1=$0
    next
}

FNR==2 {
    if (NR==2) h2=$0
    else if ($0 != h2) {
        print "ERROR: header/sample sizes differ in " FILENAME > "/dev/stderr"
        exit 1
    }
    next
}

NF > 0 {
    for (i=1; i<=NF; i++) {
        sum[i] += $i
    }
    if (NF > maxnf) maxnf = NF
}

END {
    print h1
    print h2
    for (i=1; i<=maxnf; i++) {
        printf "%s%s", sum[i], (i<maxnf ? " " : "\n")
    }
}
' "${files[@]}" > "Allsamples_nowallacei_Allsites_GENOME_MSFS.obs"
