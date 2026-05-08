#!/bin/bash

#SBATCH --job-name=cluster0.8
#SBATCH --account=tsztain_owned1
#SBATCH --partition=spgpu2
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=150GB
#SBATCH --time=24:00:00
#SBATCH --error=intermediate/cluster_pdb-bind_0.8sim.err
#SBATCH --out=intermediate/cluster_pdb-bind_0.8sim.out

echo "clustering with sequence identity 0.8 threshold"

time foldseek easy-multimercluster data/pdb-bind-receptor_pdbs/ prod/clustering_results_0.8sim/pdb-bind_clustering intermediate/cluster_tmp_0.8 --tmscore-threshold 0.8

echo "clustering complete!"

