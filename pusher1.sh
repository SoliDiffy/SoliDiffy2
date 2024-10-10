#!/bin/bash

# Configure batch size
BATCH_SIZE=1000
REMOTE="origin"
BRANCH="master"

# Get a list of all modified/untracked files into an array
mapfile -t files_to_commit < <(git ls-files --others --modified --exclude-standard)

if [[ ${#files_to_commit[@]} -eq 0 ]]; then
  echo "No changes to commit."
  exit 0
fi

# Initialize counters and timers
total_files=${#files_to_commit[@]}
total_batches=$(( (total_files + BATCH_SIZE - 1) / BATCH_SIZE ))
batch_count=0
start_time=$(date +%s)

# Process files in batches
for ((i=0; i<total_files; i+=BATCH_SIZE)); do
  # Select the current batch of files
  batch_files=("${files_to_commit[@]:i:BATCH_SIZE}")
  
  # Add files using xargs for efficiency
  printf "%s\n" "${batch_files[@]}" | xargs git add

  batch_count=$((batch_count + 1))
  echo "Committing batch #$batch_count of $total_batches..."

  git commit --quiet -m "Batch #$batch_count commit"

  echo "Pushing batch #$batch_count of $total_batches..."
  git push --quiet "$REMOTE" "$BRANCH"

  # Calculate and display elapsed and estimated remaining time
  elapsed_time=$(( $(date +%s) - start_time ))
  avg_time_per_batch=$(( elapsed_time / batch_count ))
  remaining_batches=$(( total_batches - batch_count ))
  remaining_time=$(( avg_time_per_batch * remaining_batches ))

  echo "Progress: $batch_count / $total_batches batches completed."
  printf "Elapsed time: %02d:%02d:%02d\n" $((elapsed_time/3600)) $((elapsed_time%3600/60)) $((elapsed_time%60))
  printf "Estimated remaining time: %02d:%02d:%02d\n" $((remaining_time/3600)) $((remaining_time%3600/60)) $((remaining_time%60))
done

# Final elapsed time
elapsed_time=$(( $(date +%s) - start_time ))
echo "All files committed and pushed."
printf "Total elapsed time: %02d:%02d:%02d\n" $((elapsed_time/3600)) $((elapsed_time%3600/60)) $((elapsed_time%60))

