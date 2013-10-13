#!/bin/bash

func="mpeg_based"

for expnum in 0 1 2; do
    filename="TM_Airport_period5_.exp"
    num_frames=12
    width=300
    height=300

    for opt_dect in 1 2 3; do
        for opt_delta in 1 2 3; do
            for block_size in 10 30 50 60 100; do
                for thresh in 1 3 5 7 10 15 20 30 50 70 100 150 200 250; do
                    sed "s/FILENAME/${filename}${expnum}./g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_size}/g;s/BLOCK_WIDTH/${block_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/THRESH/${thresh}/g;s/OPT_DECT/${opt_dect}/g;s/OPT_DELTA/${opt_delta}/g;" ${func}.mother.sh > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.sh
                    sed "s/XXX/${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}/g" ${func}.mother.condor > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.condor
                    condor_submit tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.condor
                done
            done
        done
    done
done




