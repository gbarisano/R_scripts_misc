#!/bin/bash
#SBATCH --job-name=keep_snake
#SBATCH --output=logs/workflow_submission_%j.log
#SBATCH --qos=long
#SBATCH --mem=2000 
#SBATCH --time=7-0
# Specify log file
MY_HOME=/scratch/users/barisano/sophia_meninges_scrnaseq/run36
cd ${MY_HOME}
DATETIME=$(date "+%Y_%m_%d_%H_%M_%S")
LOGFILE=log/snake.$DATETIME.log
source /home/groups/mghayden/software/miniconda3/bin/activate snakemake
    # deploy to cluster
    snakemake all --snakefile $MY_HOME/Snakefile --use-conda --conda-prefix /home/groups/mghayden/software/miniconda3/envs/ --cluster "sbatch --ntasks=1 --time=12:00:00 --job-name={params.name} --cpus-per-task={threads} --partition='normal' --mem={params.mem} -o $MY_HOME/slurm_output/{params.name}.%j.log" --keep-target-files -j 200 -w 100 -k -p -r --rerun-incomplete
