#!/bin/bash

# Push local input files and scripts to Bunya.
# Put a copy of this (and pull.sh) in each project directory, and set UPSTREAM.
# Extra arguments are passed to rsync, e.g. dry run (show what would be copied):
#   ./push.sh -n

# Upstream destination (remote server and path) -- same as in pull.sh
UPSTREAM="bunya:/scratch/user/uqusername/my-project/"

# File patterns to include (directories are always traversed)
PATTERNS=(
    "*.in"
    "*.sh"
    "*.slurm"
)

# Build include args from patterns
INCLUDE_ARGS=("--include=*/")
for pattern in "${PATTERNS[@]}"; do
    INCLUDE_ARGS+=("--include=$pattern")
done

# Push local files to upstream.
# Files not matching PATTERNS are excluded.
# --update: skip files that are newer upstream (never overwrite newer with older).
# --prune-empty-dirs: don't create remote copies of directories with no matching files.
rsync -avz --update --prune-empty-dirs "${INCLUDE_ARGS[@]}" --exclude='*' "$@" ./ "$UPSTREAM"
