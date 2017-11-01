#!/bin/bash
#
# SLURM job Q3 PS6 Kwarsick
#
# Job name:
#SBATCH --job-name=Q3
#
# Account:
#SBATCH --account=ic_stat243
#
# Partition:
#SBATCH --partition=savio2
#
# Resources requested:
#SBATCH --nodes=2
#
# Wall clock limit:
#SBATCH --time=01:30:00
#
## Command(s) to run:
module purge
module load java spark 
source /global/home/groups/allhands/bin/spark_helper.sh
spark-start
# putting path to test_batch.py shouldn't be necessary but
# for some reason current working directory not being used
spark-submit --master $SPARK_URL $HOME/q3.py
spark-stop