#!/bin/bash --login

### Computational resources to request (these are *per array task*):
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G
#SBATCH --partition=general

### only for bunya
#SBATCH --account=a_smp

### "Wall time" (time limit) for each task, Days-HH:MM:SS
#SBATCH --time=0-01:00:00

### Job name
#SBATCH --job-name=my-array

### One array task per input file: indices 0..(number of files - 1).
#SBATCH --array=0-13

module purge
module load foss/2024a
module load gsl/2.8-gcc-13.3.0

### Number of OpenMP threads, and BLAS/LAPACK threads.
### If your code calls BLAS from inside its own OpenMP loops, set the BLAS ones to 1.
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OPENBLAS_NUM_THREADS=$SLURM_CPUS_PER_TASK  # OpenBLAS (foss toolchain)
export MKL_NUM_THREADS=$SLURM_CPUS_PER_TASK       # Intel MKL (if used)

### Job is marked FAILED (not COMPLETED) if the program fails, even though piped to tee
set -o pipefail

### Path to the compiled program
PROGRAM=$HOME/my-code/my-program

### List of input files, sorted by name: input_files[0]=00-input.in, [1]=01-input.in, ...
### Name files with a zero-padded number first (00-, 01-, ..., 13-), so the sorted
### order is the numbered order, and array index 5 is 05-input.in.
### Each task builds this list when it starts: don't add/remove matching files
### while the array is still queued, or the indices will shift.
input_files=([0-9][0-9]-input.in)

### Alternative: wildcard '*'
# input_files=(*-input.in)

### Input and output file names - one for each array task:
input=${input_files[$SLURM_ARRAY_TASK_ID]}
output=${input%.in}.out

if [[ ! -f "$input" ]]; then
  echo "No input file for array index $SLURM_ARRAY_TASK_ID"
  exit 1
fi

$PROGRAM $input | tee -a $output
