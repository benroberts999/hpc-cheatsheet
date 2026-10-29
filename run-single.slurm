#!/bin/bash --login

### Run a single job.
### Submit from the directory containing the input file:   sbatch run-single.slurm

### Computational resources to request:
### (--cpus-per-task counts hardware threads: 2 per physical core on Bunya)
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G
#SBATCH --partition=general
### only for bunya
#SBATCH --account=a_smp

### "Wall time" (time limit), Days-HH:MM:SS. The job is killed when it hits this.
#SBATCH --time=0-12:00:00

### Job name, and Slurm log file (%x = job name, %j = job ID)
#SBATCH --job-name=my-job
#SBATCH --output=%x-%j.out

### Same modules as used to compile
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

### Input and output file names:
input=my-input.in
output=${input%.in}.out

$PROGRAM $input | tee -a $output
