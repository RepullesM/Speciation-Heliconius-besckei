#!/bin/bash
#OUT="easySFS_20Chr"
#mkdir -p "$OUT"

for pair in 1_0 2_0 2_1 3_0 3_1 3_2; do
    files=(easySFS_June2026_noWallacei/easySFS_Hmel*/fastsimcoal2/Allsamples_nowallacei_Allsites_*_jointMAFpop${pair}.obs)

    [ -e "${files[0]}" ] || { echo "No files for pop${pair}"; continue; }

    awk '
    FNR==1 {
        if (NR==1) h1=$0
        next
    }

    FNR==2 {
        if (NR==2) h2=$0
        next
    }

    {
        row = FNR-2
        label[row] = $1

        for (col=2; col<=NF; col++) {
            sum[row,col] += $col
        }

        if (NF > maxcol) maxcol = NF
        if (row > maxrow) maxrow = row
    }

    END {
        print h1
        print h2

        for (row=1; row<=maxrow; row++) {
            printf "%s", label[row]

            for (col=2; col<=maxcol; col++) {
                printf " %s", sum[row,col]
            }

            printf "\n"
        }
    }
    ' "${files[@]}" > "Allsamples_nowallacei_Allsites_GENOME_jointMAFpop${pair}.obs"

    echo "Done pop${pair}"
done
