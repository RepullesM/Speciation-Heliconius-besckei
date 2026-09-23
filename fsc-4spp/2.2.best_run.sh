#!/bin/bash

# Output file
outfile="02.output_beslhood_constrained/best_runs_summary.txt"
echo -e "filename\trun\tdiff\tMaxEstLhood\tAIC" > "$outfile"

# List of your files
files=(02.output_beslhood_constrained/results_*.txt)

for file in "${files[@]}"; do
  # Get number of columns from header
  ncols=$(head -1 "$file" | awk '{print NF}')
  max_est_col=$((ncols-1))
  max_obs_col=$ncols

  # Determine model type (IM, SC, or SI) from filename
  if [[ "$file" == *"_H0_IM_4demes.txt" ]]; then
    k=16
  elif [[ "$file" == *"_H1_IM_4demes.txt" ]]; then
    k=16
  elif [[ "$file" == *"_H2_IM_4demes.txt" ]]; then
    k=18
  elif [[ "$file" == *"_H3_IM_4demes.txt" ]]; then
    k=16
  elif [[ "$file" == *"_H4_IM_4demes.txt" ]]; then
    k=16
  elif [[ "$file" == *"_H5_IM_4demes.txt" ]]; then
    k=16
  elif [[ "$file" == *"_H6_IM_4demes.txt" ]]; then
    k=18
  else
    echo "Unknown model type in file: $file"
    continue
  fi

  # Find best run and calculate AIC
  best_line=$(tail -n +2 "$file" | awk -v est_col=$max_est_col -v obs_col=$max_obs_col -v k=$k '
    NR==1 {
      best_diff = $obs_col - $est_col
      best_run = $1
      best_obs = $obs_col
      best_est = $est_col
    }
    {
      curr_diff = $obs_col - $est_col
      if (curr_diff < best_diff) {
        best_diff = curr_diff
        best_run = $1
        best_obs = $obs_col
        best_est = $est_col
      }
    }
    END {
      aic = 2*k - 2*(best_est*log(10))
      printf "%s\t%.2f\t%.3f\t%.2f\n", best_run, best_diff, best_est, aic
    }
  ')

  # Append result to output file
  echo -e "${file}\t${best_line}" >> "$outfile"
done

echo "✅ Best runs with AIC written to $outfile"
