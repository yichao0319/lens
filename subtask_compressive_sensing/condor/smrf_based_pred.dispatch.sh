#!/bin/bash

func="smrf_based_pred"

for seed in 0 1 2 3 4 5 6 7 8 9 10; do
    filename="TM_Airport_period5_"
    num_frames=12
    width=300
    height=300

    for opt_swap_mat in 0 1 2 3; do
        for group_size in 4; do
            for rank in 1 2 3 5 7 10 20 30 50; do
                for opt_type in 0 1; do
                    for loss_rate in 0.001 0.005 0.01; do
                        echo ${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}
                        sed "s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/THRESH/${thresh}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}.sh
                        sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}.condor
                        condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.${loss_rate}.${seed}.condor
                    done
                done
            done
        done
    done
done




