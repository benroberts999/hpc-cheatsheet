#!/bin/bash --login

### Compile your code on a compute node (builds on the login node get killed).
### Submit from your code directory:   sbatch compile.slurm

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
### D-HH:MM:SS
#SBATCH --time=0-00:15:00
#SBATCH --partition=general
#SBATCH --job-name=compile

### only for bunya
#SBATCH --account=a_smp


### Compile on the oldest CPU type (epyc3), so the program runs on every node.
### Code built on epyc4/epyc5 nodes will not run on epyc3 nodes.
### only for bunya
#SBATCH --constraint=epyc3

### Same modules as used to run
module purge
module load foss/2024a
module load gsl/2.8-gcc-13.3.0

make -j $SLURM_CPUS_PER_TASK
