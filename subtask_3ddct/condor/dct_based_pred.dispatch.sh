#!/bin/bash

func="dct_based_pred"


# for filename in "TM_Airport_period5_"; do
for filename in "tm.sort_ips.ap.country.txt.3600." "tm.sort_ips.ap.gps.4.txt.3600." "tm.select_matrix_for_id-Assignment.txt.60."; do

    if [[ ${filename} == "TM_Airport_period5_" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
        num_frames=12
        width=300
        height=300

        opt_swap_mats=(0 1 2 3)
        chunk_sizes=(30 50 100)
        sel_chunkss=(1 5 10 20 30)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.country.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=9
        width=346
        height=346

        opt_swap_mats=(0 3)
        chunk_sizes=(30 50 100)
        sel_chunkss=(1 5 10 20 30)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.gps.4.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=9
        width=741
        height=741

        opt_swap_mats=(0 3)
        chunk_sizes=(70 125 247)
        sel_chunkss=(1 5 10 20 30)
    fi
    if [[ ${filename} == "tm.select_matrix_for_id-Assignment.txt.60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/signaling_tm\/"
        num_frames=12
        width=28
        height=28

        opt_swap_mats=(0 3)
        chunk_sizes=(10 14)
        sel_chunkss=(1 2 3 5 10)
    fi

    seeds=(1 2 3 4 5 6 7 8 9 10)
    loss_rates=(0.001 0.005 0.01)
    group_sizes=(4)
    opt_types=(0 1)
    quantizations=(5 10 20 30 50)


    for seed in ${seeds[@]}; do
        for loss_rate in ${loss_rates[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for group_size in ${group_sizes[@]}; do
                    for opt_type in ${opt_types[@]}; do

                        if [[ ${opt_type} -eq 0 ]]; then
                            chunk_size=0
                            sel_chunks=0

                            for quantization in ${quantizations[@]}; do
                                echo ${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}
                                sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.sh
                                sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.condor
                                condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.condor
                            done

                        elif [[ ${opt_type} -eq 1 ]]; then
                            quantization=0

                            for chunk_size in ${chunk_sizes[@]}; do
                                for sel_chunks in ${sel_chunkss[@]}; do
                                    echo ${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}
                                    sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.sh
                                    sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.condor
                                    condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.condor
                                done
                            done
                        fi
                    done
                done
            done
        done
    done
done




