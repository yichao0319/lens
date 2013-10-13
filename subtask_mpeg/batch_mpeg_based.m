

fh = fopen('../processed_data/subtask_mpeg/output/mpeg.2013.10.13.r1.output.txt', 'w');

for expnum = [0, 1, 2]
    %% mpeg based
    method     = 'MPEG';
    num_frames = 12;
    width      = 300;
    height     = 300;

    for opt_dect = [1 2 3]
        for opt_delta = [1 2 3]
            for block_size = [10, 30, 50, 60, 100]
                for thresh = [1 3 5 7 10 15 20 30 50 70 100 150 200 250]
                    [tp, tn, fp, fn, precision, recall, f1score] = mpeg_based(['TM_Airport_period5_.exp' int2str(expnum) '.'], num_frames, width, height, block_size, block_size, thresh, opt_dect, opt_delta);

                    fprintf(fh, 'TM_Airport_period5_.exp%d, %d, %d, %d, %d, %d, %d, %d, %d, %f, %f, %f\n', expnum, opt_dect, opt_delta, block_size, thresh, tp, tn, fp, fn, precision, recall, f1score);
                end
            end
        end
    end

    
end

fclose(fh);
