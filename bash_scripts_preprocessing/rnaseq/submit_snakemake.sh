#!/bin/bash
#SBATCH --time 7-0
#SBATCH --job-name workflow_submission
#SBATCH --output=logs/workflow_submission_%j.log
#SBATCH --qos long
#source activate omic-qc-wf
#snakemake -j 200 --use-conda --conda-prefix /labs/mghayden/gbarisano/software_tools/miniconda3/envs/ --rerun-incomplete --restart-times 3 --latency-wait 250 --keep-going --cluster-config cluster.json --cluster "sbatch -p {cluster.partition} -N {cluster.N}  -t {cluster.t} -o {cluster.o} -e {cluster.e} -J {cluster.J} -c {cluster.c} --mem {cluster.mem} --qos {cluster.qos}" -s Snakefile 
snakemake -j 200 --use-conda --conda-prefix /home/groups/mghayden/software/miniconda3/envs/ --rerun-incomplete --restart-times 3 --latency-wait 250 --keep-going --cluster-config cluster.json --cluster "sbatch -p {cluster.partition} -N {cluster.N}  -t {cluster.t} -o {cluster.o} -e {cluster.e} -J {cluster.J} -c {cluster.c} --mem {cluster.mem} --qos {cluster.qos}" -s Snakefile 
#If you are sure that no other instances of snakemake are running on this directory, the remaining lock was likely caused by a kill signal or a power loss. It can be removed with the --unlock argument. run snakemake --unlock within the folder to be unlocked.
