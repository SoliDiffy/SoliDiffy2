#!/bin/bash

# Configure batch size and push interval
BATCH_SIZE=1000
PUSH_EVERY_N_BATCHES=5  # Set to push every 5 batches
REMOTE="origin"
BRANCH="master"

# Get a list of all modified/untracked files
files_to_commit=($(git ls-files --others --modified --exclude-standard))
if [[ ${#files_to_commit[@]} -eq 0 ]]; then
  echo "No changes to commit."
  exit 0
fi

# Initialize counters and timers
total_files=${#files_to_commit[@]}
total_batches=$(( (total_files + BATCH_SIZE - 1) / BATCH_SIZE ))
batch_count=0
file_count=0
start_time=$(date +%s)

# Initialize an array to collect files for each batch
batch_files=()

# Process each file and add it in batches
for file in "${files_to_commit[@]}"; do
  if [[ -f $file ]]; then
    batch_files+=("$file")
    file_count=$((file_count + 1))
  fi

  # Commit and push if we reach the batch size
  if [[ $file_count -ge $BATCH_SIZE ]]; then
    batch_count=$((batch_count + 1))
    
    echo "Adding and committing batch #$batch_count of $total_batches with $file_count files..."
    git add "${batch_files[@]}"
    git commit -m "Batch #$batch_count commit - $file_count files"
    
    # Reset the file counter and clear the batch array
    file_count=0
    batch_files=()

    # Push if we've reached the push interval
    if (( batch_count % PUSH_EVERY_N_BATCHES == 0 )); then
      echo "Pushing batches up to batch #$batch_count..."
      git push "$REMOTE" "$BRANCH"
      
      # Calculate and display elapsed and estimated remaining time
      elapsed_time=$(( $(date +%s) - start_time ))
      avg_time_per_batch=$(( elapsed_time / batch_count ))
      remaining_batches=$(( total_batches - batch_count ))
      remaining_time=$(( avg_time_per_batch * remaining_batches ))

      echo "Progress: $batch_count / $total_batches batches completed."
      printf "Elapsed time: %02d:%02d:%02d\n" $((elapsed_time/3600)) $((elapsed_time%3600/60)) $((elapsed_time%60))
      printf "Estimated remaining time: %02d:%02d:%02d\n" $((remaining_time/3600)) $((remaining_time%3600/60)) $((remaining_time%60))
    fi
  fi
done

# Commit any remaining files in the final batch
if [[ $file_count -gt 0 ]]; then
  batch_count=$((batch_count + 1))
  echo "Adding and committing final batch #$batch_count with $file_count files..."
  git add "${batch_files[@]}"
  git commit -m "Batch #$batch_count commit - $file_count files"
fi

# Final push for any remaining batches
if (( batch_count % PUSH_EVERY_N_BATCHES != 0 )); then
  echo "Final push for remaining batches..."
  git push "$REMOTE" "$BRANCH"
fi

# Final elapsed time
elapsed_time=$(( $(date +%s) - start_time ))
echo "All files committed and pushed."
printf "Total elapsed time: %02d:%02d:%02d\n" $((elapsed_time/3600)) $((elapsed_time%3600/60)) $((elapsed_time%60))

