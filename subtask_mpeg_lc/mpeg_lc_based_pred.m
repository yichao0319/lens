%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.11.07 @ UT Austin
%%
%% - Input:
%%   @option_delta: options to calculate delta
%%      1: sum of absolute diff
%%      2: mean square error (MSE)
%%      3: mean absolute error (MAE)
%%   @option_scope: 
%%      0: local : for each block, find k blocks from candidate blocks whose linear combination minimizes the MSE to the current block.
%%      1: global: Find k blocks from candidate blocks whose linear combination minimizes MAE to all blocks. 
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      0: original matrix
%%      1: randomize raw and col
%%      2: geo -- can only be used by 4sq TM matrix
%%      3: correlated coefficient
%%   @drop_rate: 
%%      (0-1): drop this ratio of values in each frame and predict their values
%%      -1   : predict next frame
%%      -2   : compression (can use any frame)
%%
%% - Output:
%%
%% e.g. 
%%     [mse, mae, cc] = mpeg_lc_based_pred('../processed_data/subtask_process_4sq/TM/', 'TM_Airport_period5_', 12, 300, 300, 30, 30, 10, 1, 0, 0)
%%     [mse, mae, cc] = mpeg_lc_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm.sort_ips.ap.country.txt.3600.', 8, 346, 346, 100, 100, 10, 1, 0, 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc] = mpeg_lc_based_pred(input_TM_dir, filename, num_frames, width, height, block_width, block_height, num_sel_blocks, option_delta, option_scope, option_swap_mat, drop_rate, seed)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 0; %% block index check

    if width ~= height
        fprintf('width should be equal to height: %d, %d\n', width, height);
        return;
    end


    %% --------------------
    %% Constant
    %% --------------------


    %% --------------------
    %% Variable
    %% --------------------
    % input_errs_dir =  '../processed_data/subtask_inject_error/errs/';
    input_4sq_dir  = '../processed_data/subtask_process_4sq/TM/';


    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    num_blocks = [ceil(width/block_width), ceil(height/block_height)];


    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    data = zeros(width, height, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        data(:,:,frame+1) = tmp(1:width, 1:height);
    end
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% drop elements
    %% --------------------
    if DEBUG2, fprintf('drop elements\n'); end

    M = ones(size(data));
    if (drop_rate > 0) & (drop_rate < 1)
        num_missing = ceil(nx * drop_rate);
        for f = [1:num_frames]
            if DEBUG0, fprintf('  frame %d\n', f); end

            ind = randperm(nx);
            tmp = M(:,:,f);
            tmp(ind(1:num_missing)) = 0;
            M(:,:,f) = tmp;
        end
    elseif drop_rate == -1
        %% predict the next frame
    elseif drop_rate == -2
        %% compression
    end
            


    %% --------------------
    %% swap matrix row and column
    %% 0: original matrix
    %% 1: randomize raw and col
    %% 2: geo
    %% 3: correlated coefficient
    %% --------------------
    if DEBUG2, fprintf('swap matrix row and column\n'); end

    if option_swap_mat == 0
        %% 0: original matrix
        mapping = [1:width];
    elseif option_swap_mat == 1
        %% 1: randomize raw and col
        mapping = randperm(width);
    elseif option_swap_mat == 2
        %% 2: geo  -- only used by 4sq TM
        [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
        if DEBUG0
            fprintf('  size of location: %d, %d\n', size(location));
            fprintf('  size of mass: %d, %d\n', size(mass));
        end
        
        mapping = sort_by_lat_lng(location, width, height);

    elseif option_swap_mat == 3
        %% 3: correlated coefficient
        tmp = reshape(data, width, []);
        if DEBUG1
            fprintf('  size of the whole matrix: %d, %d\n', size(tmp));
        end
        
        coef = corrcoef(tmp');
        mapping = sort_by_coef(coef, width, height);
    end

    %% update the data matrix according to the mapping
    for f = [1:num_frames]
        data(:,:,f) = map_matrix(data(:,:,f), mapping);
        M(:,:,f)    = map_matrix(M(:,:,f), mapping);
    end

    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end
    

    compared_data = data;
    compared_data(~M) = 0;


    %% --------------------
    %% for each block, find the linear combination of other blocks
    %% --------------------
    if DEBUG2, fprintf('for each block, find the linear combination of other blocks\n'); end

    if option_scope == 0
        %% local

        %% --------------------
        %% for each block        
        for frame = [1:num_frames]
            if DEBUG0, fprintf('  frame %d\n', frame); end

            for w = [1:num_blocks(1)]
                w_s = (w-1)*block_width + 1;
                w_e = min(w*block_width, width);
                for h = [1:num_blocks(2)]
                    h_s = (h-1)*block_height + 1;
                    h_e = min(h*block_height, height);
                    if DEBUG3, fprintf('  block: [%d,%d]\n', w, h); end

                    this_block = zeros(block_width, block_height);
                    this_block(1:(w_e-w_s+1), 1:(h_e-h_s+1)) = data(w_s:w_e, h_s:h_e, frame);
                    this_block_M = zeros(block_width, block_height);
                    this_block_M(1:(w_e-w_s+1), 1:(h_e-h_s+1)) = M(w_s:w_e, h_s:h_e, frame);
                    meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                    meanX = mean(reshape(this_block(this_block_M==1), [], 1));

                    %% for linear regression
                    tmp = this_block;
                    tmp(~this_block_M) = NaN;
                    object = reshape(tmp, [], 1);
                    predictors = [-1];


                    %% ------------
                    %% Among "candidate blocks", Select "num_sel_blocks" blocks 
                    %%   whose linear combination minimizes the MSE/MAE to the current block
                    %% Candidate blocks: all blocks in previous 2 ~ next 2 frames
                    %% Greedy algorithm: find one block at a time
                    s_f = max(1, frame-2);
                    e_f = min(num_frames, frame+2);
                    this_num_sel_blocks = min(num_sel_blocks, (e_f-s_f+1)*prod(num_blocks));

                    min_delta = -1;
                    for k = [1:this_num_sel_blocks] 
                        
                        min_predictors = [-1];
                        %% --------------------
                        %% among candidate blocks
                        for f2 = [s_f:e_f]
                            for w2 = [1:num_blocks(1)]
                                w2_s = (w2-1)*block_width + 1;
                                w2_e = min(w2*block_width, width);
                                for h2 = [1:num_blocks(2)]
                                    h2_s = (h2-1)*block_height + 1;
                                    h2_e = min(h2*block_height, height);
                                    if DEBUG3, fprintf('    candidate block: [%d,%d]\n', w2, h2); end

                                    cand_block = zeros(block_width, block_height);
                                    cand_block(1:(w2_e-w2_s+1), 1:(h2_e-h2_s+1)) = data(w2_s:w2_e, h2_s:h2_e, f2);
                                    cand_block_M = zeros(block_width, block_height);
                                    cand_block_M(1:(w2_e-w2_s+1), 1:(h2_e-h2_s+1)) = M(w2_s:w2_e, h2_s:h2_e, f2);

                                    %% for linear regression
                                    cand_block(~cand_block_M) = NaN;
                                    tmp_predictors = predictors;
                                    this_predictors = reshape(cand_block, [], 1);
                                    if tmp_predictors(1, 1) == -1
                                        tmp_predictors = this_predictors;
                                    else
                                        tmp_predictors = [tmp_predictors, this_predictors];
                                    end

                                    [coefficients, bint, residuals] = regress(object, tmp_predictors);

                                    if option_delta == 1
                                        this_delta = mean(abs(residuals));
                                    elseif option_delta == 2
                                        this_delta = mean(residuals.^2)/meanX2;
                                    elseif option_delta == 3
                                        this_delta = mean(abs(residuals))/meanX;
                                    else
                                        error(['wrong option delta: ' int2str(option_delta)]);
                                    end

                                    if(this_delta < min_delta or min_delta < 0)
                                        min_delta = this_delta;
                                        min_predictors = this_predictors;
                                    end
                                end
                            end
                        end

                        %% have searched all candidate blocks
                        if min_predictors(1, 1)  == -1
                            %% cannot find one more block whose residuals are smaller
                            break;
                        else
                            %% residuals are smaller
                            if predictors(1, 1) == -1
                                predictors = min_predictors;
                            else
                                predictors = [predictors, min_predictors];
                            end
                        end
                    end  %% end of num_sel_blocks

                    %% update the missing elements of this_block in compared_data
                    [coefficients] = regress(object, predictors);
                    predictors(predictors == NaN) = 0;
                    appoximate = zeros(size(coefficients));
                    for ind = [1:length(coefficients)]
                        appoximate = appoximate + coefficients(ind) * predictors(ind, :);
                    end
                    
                    tmp = this_block;
                    tmp(~this_block_M) = appoximate(~this_block_M);
                    compared_data(w_s:w_e, h_s:h_e, frame) = tmp(1:(w_e-w_s+1), 1:(h_e-h_s+1));
                end
            end
        end  %% end for each frame
    elseif option_scope == 1
        %% global
    else
        %% local
        error(['wrong option_scope: ' int2str(option_scope) );
    end


    %% --------------------
    %% evaluate the prediction
    %% --------------------
    meanX2 = mean(data(:).^2);
    meanX = mean(data(:));
    mse = mean(( data(~M) - max(0,compared_data(~M)) ).^2) / meanX2;
    mae = mean(abs((data(~M) - max(0,compared_data(~M))))) / meanX;
    cc  = corrcoef(data(~M),max(0,compared_data(~M)));
    cc  = cc(1,2);
end





%% -------------------------------------
%% map_matrix: swap row and columns according to "mapping"
%% @input mapping: 
%%    a vector to map venues to the other
%%    e.g. [4, 3, 1, 2] means mapping 1->4, 2->3, 3->1, 4->2
%%
function [new_mat] = map_matrix(mat, mapping)
    new_mat = zeros(size(mat));
    new_mat(mapping, :) = mat;
    tmp = new_mat;
    new_mat(:, mapping) = tmp;
end


%% find_ind: function description
function [map_ind] = find_mapping_ind(ind, width, height, mapping)
    y = mod(ind-1, height) + 1;
    x = floor((ind-1)/height) + 1;

    x2 = mapping(x);
    y2 = mapping(y);
    map_ind = (x2 - 1) * height + y2;
end


%% -------------------------------------
%% sort_by_lat_lng
%% @input location: 
%%    a Nx2 matrix to represent the (lat, lng) of N venues
%%
function [mapping] = sort_by_lat_lng(location, width, height)
    mapping = ones(1, width);
    tmp = 2:width;
    src = 1;
    src_ind = 2;
    while length(tmp) > 0
        min_dist = -1;
        min_dist_dst = 0;
        min_dist_ind = 0;

        ind = 0;
        for dst = tmp
            ind = ind + 1;
            dist = pos2dist(location(src,1), location(src,2), location(dst,1), location(dst,2), 2);

            if (min_dist == -1) | (min_dist > dist) 
                min_dist = dist;
                min_dist_dst = dst;
                min_dist_ind = ind;
            end
        end

        if tmp(min_dist_ind) ~= min_dist_dst
            fprintf('min dist dst does not match: %d, %d\n', tmp(min_dist_ind), min_dist_dst);
            return;
        end

        mapping(src_ind) = min_dist_dst;
        src = min_dist_dst;
        src_ind = src_ind + 1;
        tmp(min_dist_ind) = [];
    end
end


%% -------------------------------------
%% sort_by_coef
%% @input coef: 
%%    a NxN matrix to represent the correlation coefficient of N venues
%%
function [mapping] = sort_by_coef(coef, width, height)
    mapping = ones(1, width);
    tmp = 2:width;
    src = 1;
    src_ind = 2;
    while length(tmp) > 0
        max_coef = -1;
        max_coef_dst = 0;
        max_coef_ind = 0;

        ind = 0;
        for dst = tmp
            ind = ind + 1;
            this_coef = coef(src, dst);

            if (max_coef == -1) | (this_coef > max_coef) 
                max_coef = this_coef;
                max_coef_dst = dst;
                max_coef_ind = ind;
            end
        end

        if tmp(max_coef_ind) ~= max_coef_dst
            fprintf('max coef dst does not match: %d, %d\n', tmp(max_coef_ind), max_coef_dst);
            return;
        end

        mapping(src_ind) = max_coef_dst;
        src = max_coef_dst;
        src_ind = src_ind + 1;
        tmp(max_coef_ind) = [];
    end
end