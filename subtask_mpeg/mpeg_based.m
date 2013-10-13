%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
%%
%% - Input:
%%   @option_dect: options to do anomaly detection
%%      1: just delta
%%      2: replace anomaly by approximated value
%%      3: replace anomaly by approximated value, and use DCT for the 1st frame
%%   @option_delta: options to calculate delta
%%      1: sum of absolute diff
%%      2: mean square error (MSE)
%%      3: mean absolute error (MAE)
%%
%% - Output:
%%
%% e.g. 
%%     [tp, tn, fp, fn, precision, recall, f1score] = mpeg_based('TM_Airport_period5_.exp0.', 12, 300, 300, 100, 100, 5, 1, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tp, tn, fp, fn, precision, recall, f1score] = mpeg_based(filename, num_frames, width, height, block_width, block_height, thresh, option_dect, option_delta)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------
    quantization = 10;


    %% --------------------
    %% Variable
    %% --------------------
    % input_TM_dir  = '../processed_data/subtask_process_4sq/TM/';
    input_TM_dir   = '../processed_data/subtask_inject_error/TM_err/';
    input_errs_dir =  '../processed_data/subtask_inject_error/errs/';
    output_dir = '../processed_data/subtask_mpeg/output/';


    %% --------------------
    %% Main starts
    %% --------------------
    num_blocks = [ceil(width/block_width), ceil(height/block_height)];


    %% --------------------
    %% Read anomaly ground truth
    %%  - row 1: index
    %%  - row 2: anomaly value
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read anomalies\n'); end

    data = zeros(width, height, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        this_err_file = [input_errs_dir filename int2str(frame) '.err.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_err_file); end

        if frame == 0
            ground_truth = load(this_err_file);
        else
            tmp = load(this_err_file);
            tmp(1, :) = tmp(1, :) + frame * width * height;

            ground_truth = [ground_truth, tmp];
        end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        data(:,:,frame+1) = tmp(1:width, 1:height);
    end

    if DEBUG1, fprintf('  size of ground truth: %d, %d\n', size(ground_truth)); end
    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end
    

    %% --------------------
    %% DCT to get clean frame for the first frame 
    %% --------------------
    if ismember(option_dect, [3])
        for w = [1:num_blocks(1)]
            w_s = (w-1)*block_width + 1;
            w_e = w*block_width;
            for h = [1:num_blocks(2)]
                h_s = (h-1)*block_height + 1;
                h_e = h*block_height;

                tmp = mirt_dctn(data(w_s:w_e, h_s:h_e, 1));
                tmp = round(tmp ./ quantization) .* quantization;
                pre_frame(w_s:w_e, h_s:h_e) = mirt_idctn(tmp);
            end
        end
    else
        pre_frame = data(:,:,1);
    end


    %% --------------------
    %% calculate the difference from the previous frame
    %% --------------------
    if DEBUG2, fprintf('calculate the difference from the previous frame\n'); end

    for frame = [1:num_frames]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        for w = [1:num_blocks(1)]
            w_s = (w-1)*block_width + 1;
            w_e = w*block_width;
            for h = [1:num_blocks(2)]
                h_s = (h-1)*block_height + 1;
                h_e = h*block_height;
                if DEBUG0, fprintf('  block: [%d,%d]\n', w, h); end
                
                this_block = data(w_s:w_e, h_s:h_e, frame);
                meanX2 = mean(reshape(this_block, [], 1).^2);
                meanX = mean(reshape(this_block, [], 1));

                %% ------------
                %% find the best fit block in the previous frame
                min_delta = -1;
                for w2 = [1:num_blocks(1)]
                    w2_s = (w2-1)*block_width + 1;
                    w2_e = w2*block_width;
                    for h2 = [1:num_blocks(2)]
                        h2_s = (h2-1)*block_height + 1;
                        h2_e = h2*block_height;
                        if DEBUG0
                            fprintf('    pre_frame=[%d,%d], w=%d-%d, h=%d-%d\n', size(pre_frame), w2_s, w2_e, h2_s, h2_e);
                        end

                        prev_block = pre_frame(w2_s:w2_e, h2_s:h2_e);

                        delta = prev_block - this_block;

                        if option_delta == 1
                            this_delta = mean(abs(delta(:)));
                        elseif option_delta == 2
                            this_delta = mean(delta(:).^2)/meanX2;
                        elseif option_delta == 3
                            this_delta = mean(abs(delta(:)))/meanX;
                        else
                            this_delta = -1;
                        end

                        if this_delta < 0, fprintf('!!!!!should not < 0!!!!\n'); end

                        if this_delta < min_delta | min_delta == -1
                            min_delta = this_delta;
                            min_delta_block = prev_block;
                            min_w = w2;
                            min_h = h2;
                        end
                    end
                end

                if DEBUG0, fprintf('    block (%d, %d) with min delta = %f\n', min_w, min_h, min_delta); end
                %% end find the best fit block in the previous frame
                %% ------------

                this_frame(w_s:w_e, h_s:h_e) = min_delta_block;
            end
        end


        %% ------------
        %% detect anomaly
        err_ts = abs(reshape(data(:,:,frame),[],1) - this_frame(:));
        this_frame_err_ind = find(err_ts > thresh);
        if frame == 1
            detect_err_ind = this_frame_err_ind;
        else
            detect_err_ind = [detect_err_ind; this_frame_err_ind + (frame-1)*width*height];
        end
        if DEBUG1, fprintf('    size of detect err = %d, %d\n', size(detect_err_ind)); end
        
        
        pre_frame = data(:,:,frame);
        if ismember(option_dect, [2, 3])
            pre_frame(this_frame_err_ind) = this_frame(this_frame_err_ind);
        end
    end


    tps = intersect(ground_truth(1, :), detect_err_ind);
    tp = size(tps, 2);
    fps = setdiff(detect_err_ind, ground_truth(1, :));
    fp = size(fps, 2);
    fns = setdiff(ground_truth(1, :), detect_err_ind);
    fn = size(fns, 2);
    tn = size(err_ts(:, 1), 1) - tp - fp - fn;
    
    precision = tp / (tp + fp);
    recall = tp / (tp + fn);
    f1score = 2 * precision * recall / (precision + recall);
end

