#!/bin/bash

#SBATCH --job-name=cluster0.5
#SBATCH --account=tsztain_owned1
#SBATCH --partition=spgpu2
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=150GB
#SBATCH --time=24:00:00
#SBATCH --error=intermediate/cluster_pdb-bind_0.5sim.err
#SBATCH --out=intermediate/cluster_pdb-bind_0.5sim.out

echo "clustering with sequence identity 0.5 threshold"

time foldseek easy-multimercluster data/pdb-bind-receptor_pdbs/ prod/clustering_results_0.5sim/pdb-bind_clustering intermediate/cluster_tmp_0.5 --tmscore-threshold 0.5

echo "clustering complete!"

