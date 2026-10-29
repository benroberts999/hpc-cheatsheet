#!/bin/bash

# Pull results (and inputs/scripts) back from Bunya.
# Put a copy of this (and push.sh) in each project directory, and set UPSTREAM.
# Extra arguments are passed to rsync, e.g. dry run (show what would be copied):
#   ./pull.sh -n

# Upstream source (remote server and path) -- same as in push.sh
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

# Pull new and changed files from upstream into local directory.
# --update: skip files that are newer locally (never overwrite local with older upstream).
# --prune-empty-dirs: don't create local copies of directories with no matching files.
# No --delete: files removed upstream are kept locally.
rsync -avz --update --prune-empty-dirs "${INCLUDE_ARGS[@]}" --exclude='*' "$@" "$UPSTREAM" ./
