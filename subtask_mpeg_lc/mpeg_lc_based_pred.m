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
%%      0: local : for each block, find k blocks from candidate blocks 
%%                 whose linear combination minimizes the MSE to the current block.
%%      1: global: Find k blocks from candidate blocks whose linear combination minimizes MSE to all blocks. 
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      0: original matrix
%%      1: randomize raw and col
%%      2: geo -- can only be used by 4sq TM matrix
%%      3: correlated coefficient
%%   @drop_rate: 
%%      (0-1): drop this ratio of values in each frame and predict their values
%%
%% - Output:
%%
%% e.g. 
%%     [mse, mae, cc] = mpeg_lc_based_pred('../processed_data/subtask_process_4sq/TM/', 'TM_Airport_period5_', 12, 300, 300, 30, 30, 10, 1, 0, 0, 0.05, 0)
%%     [mse, mae, cc] = mpeg_lc_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm.sort_ips.ap.country.txt.3600.', 7, 400, 400, 40, 40, 10, 1, 0, 0, 0.05, 0)
%%     [mse, mae, cc] = mpeg_lc_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm.sort_ips.ap.country.txt.3600.', 7, 400, 400, 40, 40, 70, 1, 1, 0, 0.05, 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc] = mpeg_lc_based_pred(input_TM_dir, filename, num_frames, width, height, block_width, block_height, num_sel_blocks, option_delta, option_scope, option_swap_mat, drop_rate, seed)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    warning off;
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 0; %% block index check
    DEBUG4 = 0; %% global

    if width ~= height
        fprintf('width should be equal to height: %d, %d\n', width, height);
        return;
    end


    %% --------------------
    %% Constant
    %% --------------------
    group_size = 4;


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
    num_missing = ceil(nx * drop_rate);
    for f = [1:num_frames]
        if DEBUG0, fprintf('  frame %d\n', f); end

        ind = randperm(nx);
        tmp = M(:,:,f);
        tmp(ind(1:num_missing)) = 0;
        M(:,:,f) = tmp;
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

        % sel_bit_map = zeros(num_frames, num_blocks(1), num_blocks(2));
        %% --------------------
        %% for each block        
        for f1 = [1:num_frames]
            if DEBUG0, fprintf('  frame %d\n', f1); end

            for w1 = [1:num_blocks(1)]
                w1_s = (w1-1)*block_width + 1;
                w1_e = min(w1*block_width, width);
                for h1 = [1:num_blocks(2)]
                    h1_s = (h1-1)*block_height + 1;
                    h1_e = min(h1*block_height, height);
                    if DEBUG3, fprintf('  block: [%d,%d]\n', w1, h1); end

                    this_block = zeros(block_width, block_height);
                    this_block(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1)) = data(w1_s:w1_e, h1_s:h1_e, f1);
                    this_block_M = zeros(block_width, block_height);
                    this_block_M(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1)) = M(w1_s:w1_e, h1_s:h1_e, f1);
                    meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                    meanX = mean(reshape(this_block(this_block_M==1), [], 1));

                    %% for linear regression
                    tmp = this_block;
                    tmp(~this_block_M) = NaN;
                    objective = reshape(tmp, [], 1);
                    predictors = [-1];


                    %% ------------
                    %% Among "candidate blocks", Select "num_sel_blocks" blocks 
                    %%   whose linear combination minimizes the MSE/MAE to the current block
                    %% Candidate blocks: all blocks in previous 2 ~ next 2 frames
                    %% Greedy algorithm: find one block at a time
                    s_f = max(1, f1-2);
                    e_f = min(num_frames, f1+2);
                    this_num_sel_blocks = min(num_sel_blocks, (e_f-s_f+1)*prod(num_blocks));
                    sel_bit_map = zeros(num_frames, num_blocks(1), num_blocks(2));

                    for k = [1:this_num_sel_blocks] 
                        
                        min_delta = -1;    
                        min_predictors = [-1];
                        min_f = -1;
                        min_w = -1;
                        min_h = -1;
                        %% --------------------
                        %% among candidate blocks
                        for f2 = [s_f:e_f]
                            for w2 = [1:num_blocks(1)]
                                w2_s = (w2-1)*block_width + 1;
                                w2_e = min(w2*block_width, width);
                                for h2 = [1:num_blocks(2)]
                                    %% skip the current block
                                    if (f2 == f1) & (w2 == w1) & (h2 == h1)
                                        continue;
                                    end
                                    %% skip blocks which have been selected
                                    if sel_bit_map(f2, w2, h2) == 1
                                        continue;
                                    end

                                    h2_s = (h2-1)*block_height + 1;
                                    h2_e = min(h2*block_height, height);
                                    if DEBUG0, fprintf('    candidate block: [%d,%d]\n', w2, h2); end

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

                                    [coefficients, bint, residuals] = regress(objective, tmp_predictors);
                                    residuals(isnan(residuals)) = 0;

                                    if option_delta == 1
                                        this_delta = mean(abs(residuals));
                                    elseif option_delta == 2
                                        this_delta = mean(residuals.^2)/meanX2;
                                    elseif option_delta == 3
                                        this_delta = mean(abs(residuals))/meanX;
                                    else
                                        error(['wrong option delta: ' int2str(option_delta)]);
                                    end

                                    if (this_delta < min_delta) | (min_delta < 0)
                                        min_delta = this_delta;
                                        min_predictors = this_predictors;
                                        min_f = f2;
                                        min_w = w2;
                                        min_h = h2;
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
                            sel_bit_map(min_f, min_w, min_h) = 1;
                        end
                    end  %% end of num_sel_blocks

                    if DEBUG3
                        ob_size = size(objective);
                        pd_size = size(predictors);
                        fprintf('  frame=%d(%d,%d): objective=(%d,%d), predictor=(%d,%d)\n', f1, w1, h1, ob_size, pd_size); 
                    end


                    %% update the missing elements of this_block in compared_data
                    [coefficients] = regress(objective, predictors);
                    predictors(predictors == NaN) = 0;
                    appoximate = zeros(size(objective));
                    for ind = [1:length(coefficients)]
                        appoximate = appoximate + coefficients(ind) * predictors(:, ind);
                    end
                    appoximate = reshape(appoximate, block_width, block_height);
                    
                    tmp = this_block;
                    tmp(~this_block_M) = appoximate(~this_block_M);
                    compared_data(w1_s:w1_e, h1_s:h1_e, f1) = tmp(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1));
                end
            end
        end  %% end for each frame
    elseif option_scope == 1
        %% global
        
        %% --------------------
        %% Global: select "num_sel_blocks" blocks 
        %%         whose linear combination minimizes the error to "all" blocks
        %% Candidate blocks: all blocks
        %% Greedy: select one block at a time.
        %%         e.g. select one block whose MSE to all blocks is minimal.
        %%              then select the 2nd block, 
        %%                   whose linear combination with the first one block has minimal MSE.
        %% --------------------
        sel_bit_map = zeros(num_frames, num_blocks(1), num_blocks(2));
        predictors = [-1];
        
        
        num_groups = ceil(num_frames / group_size);

        for g = 1:num_groups
            f_s = (g-1)*group_size + 1;
            f_e = min(g*group_size, num_frames);
            if(DEBUG4), fprintf('group %d: frame %d-%d\n', g, f_s, f_e); end

            this_num_sel_blocks = min(num_sel_blocks, (f_e-f_s+1)*prod(num_blocks));
            for k = [1:this_num_sel_blocks]

                min_delta = -1;
                min_predictors = [-1];
                min_f = -1;
                min_w = -1;
                min_h = -1;
                %% --------------------
                %% among candidate blocks: 
                for f2 = [f_s:f_e]
                    for w2 = [1:num_blocks(1)]
                        w2_s = (w2-1)*block_width + 1;
                        w2_e = min(w2*block_width, width);
                        for h2 = [1:num_blocks(2)]
                            %% skip blocks which have been selected
                            if sel_bit_map(f2, w2, h2) == 1
                                continue;
                            end

                            h2_s = (h2-1)*block_height + 1;
                            h2_e = min(h2*block_height, height);
                            if DEBUG4, fprintf('  candidate block: %d [%d,%d]\n', f2, w2, h2); end

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

                            %% --------------------
                            %% calculate error if adding this candidate block
                            this_delta = 0;
                            for f1 = [f_s:f_e]
                                for w1 = [1:num_blocks(1)]
                                    w1_s = (w1-1)*block_width + 1;
                                    w1_e = min(w1*block_width, width);
                                    for h1 = [1:num_blocks(2)]
                                        %% skip blocks which have been selected, bc their error will be 0
                                        if sel_bit_map(f1, w1, h1) == 1
                                            continue;
                                        end

                                        h1_s = (h1-1)*block_height + 1;
                                        h1_e = min(h1*block_height, height);

                                        this_block = zeros(block_width, block_height);
                                        this_block(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1)) = data(w1_s:w1_e, h1_s:h1_e, f1);
                                        this_block_M = zeros(block_width, block_height);
                                        this_block_M(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1)) = M(w1_s:w1_e, h1_s:h1_e, f1);
                                        meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                                        meanX = mean(reshape(this_block(this_block_M==1), [], 1));

                                        %% for linear regression
                                        this_block(~this_block_M) = NaN;
                                        objective = reshape(this_block, [], 1);

                                        if DEBUG0
                                            ob_size = size(objective);
                                            pd_size = size(tmp_predictors);
                                            fprintf('    frame=%d(%d,%d): objective=(%d,%d), predictor=(%d,%d)\n', f1, w1, h1, ob_size, pd_size); 
                                        end

                                        [coefficients, bint, residuals] = regress(objective, tmp_predictors);
                                        residuals(isnan(residuals)) = 0;
                                        
                                        if option_delta == 1
                                            this_delta = this_delta + mean(abs(residuals));
                                        elseif option_delta == 2
                                            this_delta = this_delta + mean(residuals.^2)/meanX2;
                                        elseif option_delta == 3
                                            this_delta = this_delta + mean(abs(residuals))/meanX;
                                        else
                                            error(['wrong option delta: ' int2str(option_delta)]);
                                        end
                                        if(DEBUG0), fprintf('    err %f\n', this_delta); end
                                    end
                                end
                            end
                            %% end calculate error if adding this candidate block
                            %% --------------------

                            % if(DEBUG4), fprintf('    err %f\n', this_delta); end

                            if (this_delta < min_delta) | (min_delta < 0)
                                min_delta = this_delta;
                                min_predictors = this_predictors;
                                min_f = f2;
                                min_w = w2;
                                min_h = h2;
                            end
                        end
                    end
                end  %% end for each f2

                if predictors(1, 1) == -1
                    predictors = min_predictors;
                else
                    predictors = [predictors, min_predictors];
                end
                sel_bit_map(min_f, min_w, min_h) = 1;

                if(DEBUG4), fprintf('  > %d select %d [%d, %d]: err=%f\n', k, min_f, min_w, min_h, min_delta); end
            end  %% end for k "sel_num_blocks"


            %% --------------------
            %% ok, now we have found the best "num_sel_blocks" blocks which are used to approximate blocks.
            %% next we will calculate the approximation and residuals 
            %% --------------------
            for f1 = [f_s:f_e]
                if DEBUG0, fprintf('  frame %d\n', f1); end

                for w1 = [1:num_blocks(1)]
                    w1_s = (w1-1)*block_width + 1;
                    w1_e = min(w1*block_width, width);
                    for h1 = [1:num_blocks(2)]
                        h1_s = (h1-1)*block_height + 1;
                        h1_e = min(h1*block_height, height);
                        if DEBUG0, fprintf('  block: [%d,%d]\n', w1, h1); end

                        this_block = zeros(block_width, block_height);
                        this_block(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1)) = data(w1_s:w1_e, h1_s:h1_e, f1);
                        this_block_M = zeros(block_width, block_height);
                        this_block_M(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1)) = M(w1_s:w1_e, h1_s:h1_e, f1);
                        meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                        meanX = mean(reshape(this_block(this_block_M==1), [], 1));

                        %% for linear regression
                        tmp = this_block;
                        tmp(~this_block_M) = NaN;
                        objective = reshape(tmp, [], 1);


                        if DEBUG1
                            ob_size = size(objective);
                            pd_size = size(predictors);
                            fprintf('  frame=%d(%d,%d): objective=(%d,%d), predictor=(%d,%d)\n', f1, w1, h1, ob_size, pd_size); 
                        end


                        %% update the missing elements of this_block in compared_data
                        [coefficients] = regress(objective, predictors);
                        predictors(predictors == NaN) = 0;
                        appoximate = zeros(size(objective));
                        for ind = [1:length(coefficients)]
                            appoximate = appoximate + coefficients(ind) * predictors(:, ind);
                        end
                        appoximate = reshape(appoximate, block_width, block_height);
                        
                        tmp = this_block;
                        tmp(~this_block_M) = appoximate(~this_block_M);
                        compared_data(w1_s:w1_e, h1_s:h1_e, f1) = tmp(1:(w1_e-w1_s+1), 1:(h1_e-h1_s+1));
                    end
                end
            end
        end
    else
        error(['wrong option_scope: ' int2str(option_scope)]);
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