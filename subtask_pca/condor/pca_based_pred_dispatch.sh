#!/bin/bash

func="pca_based_pred"

for loss_rate in 0.001 0.005 0.01; do
    filename="TM_Airport_period5_"
    num_frames=12
    width=300
    height=300

    for opt_swap_mat in 0 1 2 3; do
        for opt_dect in 1 2; do
            for block_size in 30 100 300; do
                for rank in 1 2 3 5 10 20 30; do
                    for seed in 1 2 3 4 5 6 7 8 9 10; do
                        echo ${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${opt_dect}.${opt_swap_mat}.${loss_rate}.${seed}
                        sed "s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_size}/g;s/BLOCK_WIDTH/${block_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/OPT_DECT/${opt_dect}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/LOSS_RATE/${loss_rate}/g;s/SEED/${seed}/g" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${opt_dect}.${opt_swap_mat}.${loss_rate}.${seed}.sh
                        sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${opt_dect}.${opt_swap_mat}.${loss_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${opt_dect}.${opt_swap_mat}.${loss_rate}.${seed}.condor
                        condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${opt_dect}.${opt_swap_mat}.${loss_rate}.${seed}.condor
                    done
                done
            done
        done
    done
done




