#!/bin/bash

/lusr/bin/matlab -r "[mse, mae, cc, ratio] = pca_based_pred('INPUT_DIR', 'FILENAME', NUM_FRAMES, WIDTH, HEIGHT, BLOCK_WIDTH, BLOCK_HEIGHT, RANK, OPT_SWAP_MAT, LOSS_RATE, SEED); fh = fopen(['/u/yichao/anomaly_compression/condor_data/subtask_pca/condor/output/pca_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.BLOCK_WIDTH.BLOCK_HEIGHT.RANK.OPT_SWAP_MAT.LOSS_RATE.SEED.txt'], 'w'); fprintf(fh, '%f, %f, %f, %f\n', mse, mae, cc, ratio); fclose(fh); exit;"

# bash run_pca_based_pred.sh /v/filer4b/software/matlab-2011a 'INPUT_DIR', 'FILENAME' NUM_FRAMES WIDTH HEIGHT BLOCK_WIDTH BLOCK_HEIGHT RANK OPT_SWAP_MAT LOSS_RATE SEED
