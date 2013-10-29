#!/bin/bash

matlab -r "[mse, mae, cc] = pca_based_pred('FILENAME', NUM_FRAMES, WIDTH, HEIGHT, BLOCK_WIDTH, BLOCK_HEIGHT, RANK, OPT_DECT, OPT_SWAP_MAT, LOSS_RATE, SEED); fh = fopen(['/u/yichao/anomaly_compression/condor_data/subtask_pca/condor/output/pca_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.BLOCK_WIDTH.BLOCK_HEIGHT.RANK.OPT_DECT.OPT_SWAP_MAT.LOSS_RATE.SEED.txt'], 'w'); fprintf(fh, '%f, %f, %f\n', mse, mae, cc); fclose(fh); exit;"