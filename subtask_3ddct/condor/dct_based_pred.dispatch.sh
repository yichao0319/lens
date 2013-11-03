#!/bin/bash

func="dct_based_pred"

for seed in 1 2 3 4 5 6 7 8 9 10; do
    for loss_rate in 0.001 0.005 0.01; do
        # ipnut_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
        # filename="TM_Airport_period5_"
        # num_frames=12
        # width=300
        # height=300
        ipnut_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        filename="tm.sort_ips.ap.country.txt.3600."
        num_frames=8
        width=346
        height=346

        # for opt_swap_mat in 0 1 2 3; do
        for opt_swap_mat in 0 3; do
            for group_size in 4; do
                for opt_type in 0 1; do

                    if [[ ${opt_type} -eq 0 ]]; then
                        chunk_size=0
                        sel_chunks=0

                        for quantization in 5 10 20 30 50; do
                            echo ${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}
                            sed "s/INPUT_DIR/${ipnut_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.sh
                            sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.condor
                            condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.condor
                        done

                    elif [[ ${opt_type} -eq 1 ]]; then
                        quantization=0

                        for chunk_size in 30 50 100; do
                            for sel_chunks in 1 5 10 20 30; do
                                echo ${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}
                                sed "s/INPUT_DIR/${ipnut_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.${chunk_size}.${chunk_size}.${sel_chunks}.${quantization}.${loss_rate}.${seed}.sh
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




