#!/bin/bash

func="srmf_based_pred"

num_jobs=200
cnt=0

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag

# files=("tm_totem." "X" "tm_3g_region_all.res0.006.bin10.sub." "tm_download.sjtu_wifi.ap_load.600.txt")
# files=("tm_3g.cell.bs.bs6.all.bin10.txt")
files=("tm_3g.cell.bs.bs1.all.bin10.txt")

for filename in ${files[@]}; do

    #############
    ## WiFi
    if [[ ${filename} == "tm_upload.sjtu_wifi.ap_load.600.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=100
        width=250
        height=1

        group_sizes=(100)
        ranks=(100)
    fi
    if [[ ${filename} == "tm_download.sjtu_wifi.ap_load.600.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=100
        width=250
        height=1

        group_sizes=(100)
        ranks=(100)
    fi
    ###############
    ## 3G
    if [[ ${filename} == "tm_3g_region_all.res0.006.bin10.sub." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=100
        width=21
        height=26

        group_sizes=(100)
        ranks=(100)
    fi
    if [[ ${filename} == "tm_3g.cell.bs.bs1.all.bin10.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
        num_frames=100
        width=458
        height=1

        group_sizes=(100)
        ranks=(100)
    fi
    if [[ ${filename} == "tm_3g.cell.bs.bs6.all.bin10.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
        num_frames=100
        width=240
        height=1

        group_sizes=(100)
        ranks=(100)
    fi
    #############
    ## GEANT
    if [[ ${filename} == "tm_totem." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_totem\/tm\/"
        num_frames=100
        width=23
        height=23

        group_sizes=(100)
        ranks=(8)
    fi
    #############
    ## Abilene
    if [[ ${filename} == "X" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/abilene\/"
        num_frames=100
        width=121
        height=1

        group_sizes=(100)
        ranks=(8)
    fi


    seeds=(1 2 3 4 5)
    opt_swap_mats=("org")
    opt_types=("srmf_knn" "lens_knn2" "srmf_lens_knn" "srmf_lens_knn2")
    opt_dims=("2d")

    sigma_mags=(0 0.2 0.4 0.6 0.8 1)
    sigma_noises=(0)
    threshs=(-1)


    for seed in ${seeds[@]}; do
        for group_size in ${group_sizes[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for rank in ${ranks[@]}; do
                    for opt_type in ${opt_types[@]}; do
                        for opt_dim in ${opt_dims[@]}; do

                            for sigma_mag in ${sigma_mags[@]}; do
                                for sigma_noise in ${sigma_noises[@]}; do
                                    for thresh in ${threshs[@]}; do

                                        ## PureRandLoss: elem_frac = 1
                                        drop_ele_mode="elem"
                                        drop_mode="ind"
                                        elem_fracs=(1)
                                        loss_rates=(0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                        burst_size=1
                                        for elem_frac in ${elem_fracs[@]}; do
                                            for loss_rate in ${loss_rates[@]}; do    
                                                name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                echo ${name}
                                                sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                # condor_submit tmp.${name}.condor
                                                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                cnt=$((${cnt} + 1))
                                            done
                                        done

                                    
                                        # ## PureRandLoss: elem_frac = 1
                                        # ## xxElemRandLoss: xx = elem_frac
                                        # ## xxTimeRandLoss: xx = loss_rate
                                        # drop_ele_mode="elem"
                                        # drop_mode="ind"
                                        # elem_fracs=(0.1 0.2 0.4 0.6 1)
                                        # loss_rates=(0.1 0.2 0.4 0.6 0.8)
                                        # burst_size=1
                                        # for elem_frac in ${elem_fracs[@]}; do
                                        #     for loss_rate in ${loss_rates[@]}; do    
                                        #         name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                        #         echo ${name}
                                        #         sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                        #         sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                        #         # condor_submit tmp.${name}.condor
                                        #         echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                        #         cnt=$((${cnt} + 1))
                                        #     done
                                        # done

                                        # ## xxElemSyncLoss: xx = elem_frac
                                        # drop_ele_mode="elem"
                                        # drop_mode="syn"
                                        # elem_fracs=(0.3)
                                        # loss_rates=(0.1 0.2 0.4 0.6 0.8)
                                        # burst_size=1
                                        # for elem_frac in ${elem_fracs[@]}; do
                                        #     for loss_rate in ${loss_rates[@]}; do    
                                        #         name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                        #         echo ${name}
                                        #         sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                        #         sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                        #         # condor_submit tmp.${name}.condor
                                        #         echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                        #         cnt=$((${cnt} + 1))
                                        #     done
                                        # done
                                        
                                        # ## RowRandLoss:
                                        # ## ColRandLoss:
                                        # drop_ele_modes=("row" "col")
                                        # drop_mode="ind"
                                        # elem_fracs=(0.1 0.2 0.4 0.6 0.8)
                                        # loss_rates=(0.5)
                                        # burst_size=1
                                        # for drop_ele_mode in ${drop_ele_modes[@]}; do
                                        #     for elem_frac in ${elem_fracs[@]}; do
                                        #         for loss_rate in ${loss_rates[@]}; do
                                        #             name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                        #             echo ${name}
                                        #             sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                        #             sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                        #             # condor_submit tmp.${name}.condor
                                        #             echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                        #             cnt=$((${cnt} + 1))
                                        #         done
                                        #     done
                                        # done

                                    done
                                done
                            done
                            
                        done
                    done
                done
            done
        done
    done
done

echo $cnt / $num_jobs

condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



