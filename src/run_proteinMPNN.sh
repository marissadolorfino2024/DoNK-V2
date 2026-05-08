#!/bin/bash

#SBATCH --job-name=mpnn
#SBATCH --account=tsztain_owned1
#SBATCH --partition=spgpu2
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=150GB
#SBATCH --time=10:00:00
#SBATCH --error=/nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026/intermediate/pmpnn_c0.5_T0.1.err
#SBATCH --out=/nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026/intermediate/pmpnn_c0.5_T0.1.out

source activate mlfold

# note that this script must be run from the ProteinMPNN directory

result_file=/nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026/prod/proteinMPNN_results_cluster0.5_T0.1.csv

# create the output csv file with correct header
echo "pdb_id,seq1,score1,global_score1,seq_recov1,seq2,score2,global_score2,seq_recov2,seq3,score3,global_score3,seq_recov3,time" > $result_file

for dir in /nfs/turbo/umms-maom/projects/MPProjects/chemical_space/dock_dev/donk_v2_05-2026/data/cluster_reps_0.5cutoff/*pdb
do
        folder_with_pdbs="${dir}"
        output_dir="${dir}"

        if [ ! -d $output_dir ]; then
        mkdir -p $output_dir
        fi

        path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"

        # parse multiple chains
        python helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

        REAL_TIME=$({ time python protein_mpnn_run.py \
        --jsonl_path $path_for_parsed_chains \
        --out_folder $output_dir \
        --num_seq_per_target 2 \
        --sampling_temp "0.1" \
        --seed 37 \
        --batch_size 1 >/dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')

        # convert from "0m4.736s" format to seconds
        REAL_TIME=$(echo $REAL_TIME | awk -F'[ms]' '{print $1*60 + $2}')

        # Initialize arrays
        declare -a pdb_ids
        declare -a scores
        declare -a global_scores
        declare -a seq_recoveries
        declare -a sequences

        # Counter for sequences
        seq_count=0

        for file in ${output_dir}/seqs/*.fa
        do
        while IFS= read -r line; do
                if [[ $line == ">"* ]]; then
                ((seq_count++))

                # get the pdb id (only from first sequence)
                if [[ $seq_count -eq 1 ]]; then
                        pdb_id=$(echo "$line" | sed 's/^>//' | cut -d'_' -f1 | cut -d',' -f1)
                        pdb_ids[$seq_count]=$pdb_id
                fi
                
                # Extract score (the first "score=" after a comma-space)
                score=$(echo "$line" | grep -oP ', score=\K[0-9.]+')
                
                # Extract global_score
                global_score=$(echo "$line" | grep -oP ', global_score=\K[0-9.]+')
                
                # Extract seq_recovery
                seq_recovery=$(echo "$line" | grep -oP ', seq_recovery=\K[0-9.]+')
                
                # For the entry sequence, seq recovery is always 1
                if [[ $seq_count -eq 1 ]]; then
                        seq_recovery="1"
                fi
                
                # Store values
                scores[$seq_count]=$score
                global_scores[$seq_count]=$global_score
                seq_recoveries[$seq_count]=$seq_recovery
                
                # Read the next line (the actual sequence)
                IFS= read -r sequence
                sequences[$seq_count]=$sequence
                fi
        done < $file
        done

        # Access the individual values
        pdb_id="${pdb_ids[1]}"
        seq1="${sequences[1]}"
        score1="${scores[1]}"
        global_score1="${global_scores[1]}"
        seq_recovery1="${seq_recoveries[1]}"

        seq2="${sequences[2]}"
        score2="${scores[2]}"
        global_score2="${global_scores[2]}"
        seq_recovery2="${seq_recoveries[2]}"

        seq3="${sequences[3]}"
        score3="${scores[3]}"
        global_score3="${global_scores[3]}"
        seq_recovery3="${seq_recoveries[3]}"

        # Write values to result file
        echo "${pdb_id},${seq1},${score1},${global_score1},${seq_recovery1},${seq2},${score2},${global_score2},${seq_recovery2},${seq3},${score3},${global_score3},${seq_recovery3},${REAL_TIME}" >> $result_file
done