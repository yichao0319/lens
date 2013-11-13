#!/bin/bash

func="mpeg_lc_based_pred"


# for filename in "TM_Airport_period5_" "tm.sort_ips.ap.gps.5.txt.3600." "tm.select_matrix_for_id-Assignment.txt.60." "tm.sort_ips.ap.country.txt.3600." "tm.sort_ips.ap.bgp.8.txt.3600." "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600." ; do
# for filename in "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600."; do
for filename in "tm.sort_ips.ap.gps.1.sub_CN.txt.3600." "tm.sort_ips.ap.country.txt.3600."  "tm.sort_ips.ap.bgp.8.txt.3600."; do


    #############
    if [[ ${filename} == "TM_Airport_period5_" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
        num_frames=12
        width=300
        height=300

        block_sizes=(30)
        num_sel_blocks2=(10 50 100 200)
    fi
    #######################
    if [[ ${filename} == "tm.select_matrix_for_id-Assignment.txt.60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/signaling_tm\/"
        num_frames=12
        width=28
        height=28

        block_sizes=(10 14 28)
        num_sel_blocks2=(5 10 20)
    fi
    #######################
    if [[ ${filename} == "tm.sort_ips.ap.country.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=8
        width=400
        height=400

        block_sizes=(40 100)
        num_sel_blocks2=(4 8 16)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.gps.5.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=8
        width=738
        height=738

        block_sizes=(70 125)
        num_sel_blocks2=(4 8 16)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.gps.1.sub_CN.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=8
        width=410
        height=410

        block_sizes=(41 103)
        num_sel_blocks2=(4 8 16)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.bgp.8.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=8
        width=421
        height=421

        block_sizes=(43 106)
        num_sel_blocks2=(4 8 16)
    fi
    if [[ ${filename} == "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=8
        width=403
        height=403

        block_sizes=(41 101)
        num_sel_blocks2=(4 8 16 64)
    fi


    seeds=(1 2 3 4 5 6 7 8 9 10)
    opt_swap_mats=(0 1 3)
    drop_rates=(0.005 0.01 0.05)
    opt_deltas=(1)
    opt_scopes=(0 1)
    opt_sel_methods=(1)
    num_sel_blocks1=(4 8 16 64)


    for seed in ${seeds[@]}; do
        for drop_rate in ${drop_rates[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for opt_delta in ${opt_deltas[@]}; do
                    for opt_scope in ${opt_scopes[@]}; do
                        if [[ $opt_scope -eq 0 ]]; then
                            num_sel_blocks=${num_sel_blocks1[@]}
                        fi
                        if [[ $opt_scope -eq 1 ]]; then
                            num_sel_blocks=${num_sel_blocks2[@]}
                        fi

                        for opt_sel_method in ${opt_sel_methods[@]}; do
                            for num_sel_block in ${num_sel_blocks[@]}; do
                                for block_size in ${block_sizes[@]}; do
                                    echo ${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${num_sel_block}.${opt_delta}.${opt_scope}.${opt_sel_method}.${opt_swap_mat}.${drop_rate}.${seed}
                                    sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_size}/g;s/BLOCK_WIDTH/${block_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/OPT_DELTA/${opt_delta}/g; s/NUM_SEL_BLOCKS/${num_sel_block}/g; s/OPT_SCOPE/${opt_scope}/g; s/OPT_SEL_METHOD/${opt_sel_method}/g;; s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/SEED/${seed}/g;s/DROP_RATE/${drop_rate}/g" ${func}.mother.sh > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${num_sel_block}.${opt_delta}.${opt_scope}.${opt_sel_method}.${opt_swap_mat}.${drop_rate}.${seed}.sh
                                    sed "s/XXX/${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${num_sel_block}.${opt_delta}.${opt_scope}.${opt_sel_method}.${opt_swap_mat}.${drop_rate}.${seed}/g" ${func}.mother.condor > tmp.${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${num_sel_block}.${opt_delta}.${opt_scope}.${opt_sel_method}.${opt_swap_mat}.${drop_rate}.${seed}.condor
                                    condor_submit tmp.${func}.${filename}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${num_sel_block}.${opt_delta}.${opt_scope}.${opt_sel_method}.${opt_swap_mat}.${drop_rate}.${seed}.condor
                                done
                            done
                        done
                    done
                done
            done
        done
    done
done


