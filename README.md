# Bunya HPC: quick guide

Example Slurm scripts for UQ's Bunya cluster. Official docs: [Bunya User Guide](https://github.com/UQ-RCC/hpc-docs/blob/main/guides/Bunya-User-Guide.md).

Replace the placeholders (`uqusername`, `my-program`, `my-input.in`, ...)

## Connecting

Add `ssh-config-additions.txt` to `~/.ssh/config`, run `mkdir -p ~/.ssh/sockets`, then `ssh bunya` or `ssh friday`.

- **Bunya** asks for your password and Okta every login. The config reuses one login for an hour, so `push.sh`/`pull.sh` don't ask again.
- **Friday** uses port 2022. With an ssh key, there's no password or Okta.
- **SSH keys:** [GitHub's guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). In short: `ssh-keygen -t ed25519`, then `ssh-copy-id friday`.

## Rules

- **The login node** is for editing, copying and submitting only. Compile and run as jobs.
- **Run jobs in scratch:** `/scratch/user/uqusername`. Nothing is backed up, and files in scratch not used for 90 days are deleted. Pull results back.
- **Compile on epyc3** (`compile.slurm` does this). Code compiled on newer nodes won't run on older ones.
- **Load the same modules** to compile and to run.

## Jobs

```bash
sbatch run-single.slurm     # submit
squeue --me                 # your queued/running jobs
scancel JOBID               # cancel
seff JOBID                  # CPU and memory efficiency of a finished job
```

Interactive shell on a compute node (for testing):

```bash
salloc --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --mem=8G --time=01:00:00 \
  --partition=general --qos=debug --account=a_smp srun --pty /bin/bash -l
```

## Array jobs

Name the input files `00-input.in`, `01-input.in`, ..., with the zero-padded number first. Then the sorted order is the numbered order, and array task 5 runs `05-input.in`.

- 14 files: `--array=0-13`
- Re-run some tasks: `sbatch --array=5,6 run-array.slurm`

## Efficiency: `sacct`

```
JobID           JobName      NCPUS   NNodes   NTasks    Elapsed    CPUTime   TotalCPU     MaxRSS      State
------------ ---------- ---------- -------- -------- ---------- ---------- ---------- ---------- ----------
29120275         my-job        192        1            07:34:58 60-15:53:36 41-16:43:+             COMPLETED
29120275.ba+      batch        192        1        1   07:34:58 60-15:53:36 41-16:43:+  86027224K  COMPLETED
29120275.ex+     extern        192        1        1   07:34:59 60-15:56:48  00:00.001          0  COMPLETED
```

(`+` means a value was cut off. The column widths in `bashrc-additions.txt` fix that.)

| Column     | Meaning                                                       |
| ---------- | ------------------------------------------------------------- |
| `CPUTime`  | `NCPUS × Elapsed`: CPU time allocated (what you're charged)   |
| `TotalCPU` | CPU time actually used                                        |
| `MaxRSS`   | Peak memory (shown on the `.batch` line)                      |

Times are `D-HH:MM:SS`. Ignore the `.extern` line.

- **CPU efficiency = TotalCPU / CPUTime** = 1001 h / 1456 h = **69%**. Below about 70%, try fewer CPUs and compare `Elapsed`.
- **Memory:** 86027224K = 82 GB, so request `--mem=100G`.
- On Bunya, 192 CPUs = 96 physical cores × 2 hyperthreads.
