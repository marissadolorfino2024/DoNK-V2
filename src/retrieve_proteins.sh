#!/bin/bash

#SBATCH --job-name=retrieve
#SBATCH --account=tromeara0
#SBATCH --partition=standard
##SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
##SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=20GB
#SBATCH --time=3:00:00
#SBATCH --error=intermediate/retrieve_proteins.err
#SBATCH --out=intermediate/retrieve_proteins.out

echo "retrieving pdbs"

# cd to the directory of protein-ligand complexes
cd /nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026/data/pdb-bind-PLs

# retrieve on the protein pdb (without ligand)
for pdb in */*/*_protein.pdb
do
    cp ${pdb} /nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026/data/pdb-bind-receptor_pdbs/
done

# cd back to parent dir
cd /nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026

echo "retrieval complete!"