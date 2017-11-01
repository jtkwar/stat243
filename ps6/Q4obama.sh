#!/bin/bash
# Job name:
#SBATCH --job-name=Q4Obama
#
# Account:
#SBATCH --account=ic_stat243
#
# Partition:
#SBATCH --partition=savio2
# Request one node:
#SBATCH--nodes=1
#
# Wall clock limit (1 hour 30 minutes here):
#SBATCH --time=01:30:00
#
## Command(s) to run:
module load r/3.2.5
R CMD BATCH --no-save obamaR.R obama.out
