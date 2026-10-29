#!/bin/bash

# Two-way sync with Bunya: push, then pull. For each file, the newest copy wins.
# Only files matching PATTERNS are synced.
# Put a copy of this in each project directory, and set UPSTREAM.
# Extra arguments are passed to rsync, e.g. dry run (show what would be copied):
#   ./sync.sh -n

# Upstream (remote server and path) -- same as in push.sh and pull.sh
UPSTREAM="bunya:/scratch/user/uqusername/my-project/"

# File patterns to include (directories are always traversed)
PATTERNS=(
    "*.in"
    "*.sh"
    "*.slurm"
    "*.out"
)

# Build include args from patterns
INCLUDE_ARGS=("--include=*/")
for pattern in "${PATTERNS[@]}"; do
    INCLUDE_ARGS+=("--include=$pattern")
done

# --update: skip files that are newer on the receiving side, so the newest copy wins.
# Push first: files newer locally go up. Then pull: files newer upstream come down.
# -a keeps modification times, so files just pushed are not pulled straight back.
# No --delete: a file deleted on one side is copied back from the other.
echo "== push =="
rsync -avz --update --prune-empty-dirs "${INCLUDE_ARGS[@]}" --exclude='*' "$@" ./ "$UPSTREAM"
echo "== pull =="
rsync -avz --update --prune-empty-dirs "${INCLUDE_ARGS[@]}" --exclude='*' "$@" "$UPSTREAM" ./
