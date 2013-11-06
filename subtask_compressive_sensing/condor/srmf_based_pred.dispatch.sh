#!/bin/bash

func="srmf_based_pred"


# for filename in "TM_Airport_period5_"; do
for filename in "tm.sort_ips.ap.country.txt.3600." "tm.sort_ips.ap.gps.4.txt.3600." "tm.select_matrix_for_id-Assignment.txt.60."; do

    if [[ ${filename} == "TM_Airport_period5_" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
        num_frames=12
        width=300
        height=300

        opt_swap_mats=(0 1 2 3)
        ranks=(1 2 3 5 7 10 20 30 50)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.country.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=9
        width=346
        height=346

        opt_swap_mats=(0 3)
        ranks=(1 2 3 5 7 10 20 30 50)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.gps.4.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=9
        width=741
        height=741

        opt_swap_mats=(0 3)
        ranks=(1 2 3 5 7 10 20 30 50)
    fi
    if [[ ${filename} == "tm.select_matrix_for_id-Assignment.txt.60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/signaling_tm\/"
        num_frames=12
        width=28
        height=28

        opt_swap_mats=(0 3)
        ranks=(1 2 3 5 7 10)
    fi

    seeds=(1 2 3 4 5 6 7 8 9 10)
    loss_rates=(0.001 0.005 0.01)
    group_sizes=(4)
    opt_types=(0 1)
    

    for seed in ${seeds[@]}; do
        for loss_rate in ${loss_rates[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for group_size in ${group_sizes[@]}; do
                    for rank in ${ranks[@]}; do
                        for opt_type in ${opt_types[@]}; do
                            echo ${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}
                            sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/THRESH/${thresh}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}.sh
                            sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}.condor
                            condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}.condor
                        done
                    done
                done
            done
        done
    done
done




