%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.26 @ UT Austin
%%
%% - Input:
%%   @option_delta: options to calculate delta
%%      1: sum of absolute diff
%%      2: mean square error (MSE)
%%      3: mean absolute error (MAE)
%%   @option_frames: determine which realted frames to compare
%%      -m: the previous m-th frame
%%      0 : current frame
%%      n : the next n-th frame
%%   @option_blocks: determine which related blocks to compare
%%      -1: all blocks
%%      0 : corresponding block
%%      4 : near by 5 blocks
%%      8 : near by 9 blocks
%%
%%      24 20 9  13 21
%%      19 8  1  5  14
%%      12 4  0  2  10
%%      18 7  3  6  15
%%      23 17 11 16 22
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      0: original matrix
%%      1: randomize raw and col
%%      2: geo
%%      3: correlated coefficient
%%   @loss_rate: 
%%      (0-1): drop elements for prediction
%%      0    : compression
%%
%% - Output:
%%
%% e.g. 
%%     [mse, mae, cc, ratio] = mpeg_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 8, 217, 400, 22, 40, 1, [-2, -1, 0, 1, 2], [0,  8, 8, 8, 0], 0, 0.05, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc, ratio] = mpeg_based_pred(input_TM_dir, filename, num_frames, width, height, block_width, block_height, option_delta, option_frames, option_blocks, option_swap_mat, loss_rate, seed)
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0; %% block index check
    DEBUG_WRITE = 0;

    % if width ~= height
    %     fprintf('width should be equal to height: %d, %d\n', width, height);
    %     return;
    % end


    %% --------------------
    %% Constant
    %% --------------------
    quantization = 10;
    ele_size = 32;  %% size of each elements in bits


    %% --------------------
    %% Variable
    %% --------------------
    % input_4sq_dir  = '../processed_data/subtask_process_4sq/TM/';
    % output_dir = '../processed_data/subtask_mpeg/output/';
    space = 0;


    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    num_blocks = [ceil(height/block_height), ceil(width/block_width)];


    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    data = zeros(height, width, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        data(:,:,frame+1) = tmp(1:height, 1:width);
    end
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% drop elements
    %% --------------------
    if DEBUG2, fprintf('drop elements\n'); end

    M = ones(size(data));
    if loss_rate > 0
        %% prediction
        num_missing = ceil(nx * loss_rate);
        for f = [1:num_frames]
            if DEBUG0, fprintf('  frame %d\n', f); end

            ind = randperm(nx);
            tmp = M(:,:,f);
            tmp(ind(1:num_missing)) = 0;
            M(:,:,f) = tmp;
        end
    else
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
        mapping_rows = [1:height];
        mapping_cols = [1:width];
    elseif option_swap_mat == 1
        %% 1: randomize raw and col
        mapping_rows = randperm(height);
        mapping_cols = randperm(width);
    elseif option_swap_mat == 2
        %% 2: geo -- only for 4sq TM
        % [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
        % if DEBUG0
        %     fprintf('  size of location: %d, %d\n', size(location));
        %     fprintf('  size of mass: %d, %d\n', size(mass));
        % end
        
        % mapping = sort_by_lat_lng(location, width, height);

    elseif option_swap_mat == 3
        %% 3: correlated coefficient
        
        tmp_rows = reshape(data, height, []);
        tmp_cols = zeros(height*num_frames, width);
        for f = [1:num_frames]
            tmp_cols( (f-1)*height+1:f*height, : ) = data(:,:,f);
        end

        %% corrcoef: rows=obervations, col=features
        coef_rows = corrcoef(tmp_rows');
        coef_cols = corrcoef(tmp_cols);

        mapping_rows = sort_by_coef(coef_rows);
        mapping_cols = sort_by_coef(coef_cols);

    elseif option_swap_mat == 4
        %% 4: popularity
        error('swap according to popularity: not done yet\n');
        
    end

    %% update the data matrix according to the mapping
    for f = [1:num_frames]
        data(:,:,f) = map_matrix(data(:,:,f), mapping_rows, mapping_cols);
        M(:,:,f)    = map_matrix(M(:,:,f), mapping_rows, mapping_cols);
    end

    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end
    

    %% --------------------    
    %% first guess of missing elements
    %% --------------------
    if loss_rate > 0
        %% prediction

        %% by 0s
        % compared_data = data;
        % compared_data(~M) = 0;
        
        %% by mean of other elements
        % compared_data = data;
        % compared_data(~M) = mean(reshape(data(M==1), [], 1));

        %% by average of nearby elements
        compared_data = first_guess('avg', data, M);
    else
        %% compression
        compared_data = data;
    end

    
    %% --------------------
    %% calculate the difference from the nearby blocks
    %% --------------------
    if DEBUG2, fprintf('calculate the difference from the nearby blocks\n'); end

    sel_bit_map = zeros(num_blocks(1), num_blocks(2), num_frames);
    for frame = [1:num_frames]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        for w = [1:num_blocks(2)]
            w_s = (w-1)*block_width + 1;
            w_e = min(w*block_width, width);
            for h = [1:num_blocks(1)]
                h_s = (h-1)*block_height + 1;
                h_e = min(h*block_height, height);
                if DEBUG3, fprintf('  block: [%d,%d]\n', h, w); end
                
                this_block = zeros(block_height, block_width);
                this_block(1:(h_e-h_s+1), 1:(w_e-w_s+1)) = compared_data(h_s:h_e, w_s:w_e, frame);
                this_block_M = zeros(block_height, block_width);
                this_block_M(1:(h_e-h_s+1), 1:(w_e-w_s+1)) = M(h_s:h_e, w_s:w_e, frame);
                
                meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                meanX = mean(reshape(this_block(this_block_M==1), [], 1));

                %% ------------
                %% find the best fit block in the specified frames
                min_delta = -1;
                for ci = [1:length(option_frames)]
                    if DEBUG3, fprintf('    compare f:%d, b:%d\n', option_frames(ci), option_blocks(ci)); end

                    comp_frame = frame + option_frames(ci);
                    if (frame == 1) & (comp_frame < 1)
                        comp_frame = 1;
                    end

                    if (comp_frame < 1) | (comp_frame > num_frames)
                        continue;
                    end

                    [w2s, h2s] = find_block_ind(w, h, num_blocks, option_blocks(ci));
                    if DEBUG0, fprintf('    w2s:%d, h2s:%d\n', length(w2s), length(h2s)); end

                    for ind2 = [1:length(w2s)]
                        w2 = w2s(ind2);
                        w2_s = (w2-1)*block_width + 1;
                        w2_e = min(w2*block_width, width);

                        h2 = h2s(ind2);
                        h2_s = (h2-1)*block_height + 1;
                        h2_e = min(h2*block_height, height);

                        %% skip the current block
                        if (comp_frame == frame) & (w2 == w) & (h2 == h)
                            continue;
                        end

                        if DEBUG3
                            fprintf('    - f%d blocks [%d,%d], h=%d-%d, w=%d-%d\n', comp_frame, h2, w2, h2_s, h2_e, w2_s, w2_e);
                        end

                        prev_block = zeros(block_height, block_width);
                        prev_block(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = compared_data(h2_s:h2_e, w2_s:w2_e, comp_frame);
                        
                        delta = prev_block(this_block_M==1) - this_block(this_block_M==1);

                        if option_delta == 1
                            this_delta = mean(abs(delta(:)));
                        elseif option_delta == 2
                            this_delta = mean(delta(:).^2)/meanX2;
                        elseif option_delta == 3
                            this_delta = mean(abs(delta(:)))/meanX;
                        else
                            this_delta = -1;
                        end

                        if this_delta < 0
                            error('!!!!!should not < 0!!!!\n'); 
                        end


                        if this_delta < min_delta | min_delta == -1
                            min_delta = this_delta;
                            min_delta_block = prev_block;
                            min_w = w2;
                            min_h = h2;
                            min_f = comp_frame;
                        end
                    end
                end
                if DEBUG0, fprintf('    frame %d block (%d, %d) with min delta = %f\n', min_f, min_h, min_w, min_delta); end
                %% end find the best fit block in the previous frame
                %% ------------

                if loss_rate > 0
                    %% prediction
                    %% update the missing elements of this_block in compared_data
                    tmp = this_block;
                    tmp(~this_block_M) = min_delta_block(~this_block_M);
                    compared_data(h_s:h_e, w_s:w_e, frame) = tmp(1:(h_e-h_s+1), 1:(w_e-w_s+1));
                else
                    %% compression
                    compared_data(h_s:h_e, w_s:w_e, frame) = min_delta_block(1:(h_e-h_s+1), 1:(w_e-w_s+1));
                end

                sel_bit_map(min_h, min_w, min_f) = 1;
            end
        end
    end
    space = block_width * block_height * length(find(sel_bit_map == 1)) * ele_size;


    meanX2 = mean(data(:).^2);
    meanX = mean(data(:));
    
    if loss_rate > 0
        %% prediction
        mse = mean(( data(~M) - max(0,compared_data(~M)) ).^2) / meanX2;
        mae = mean(abs((data(~M) - max(0,compared_data(~M))))) / meanX;
        cc  = corrcoef(data(~M),max(0,compared_data(~M)));
        cc  = cc(1,2);
    else
        %% compression
        mse = mean(( data(:) - max(0,compared_data(:)) ).^2) / meanX2;
        mae = mean(abs((data(:) - max(0,compared_data(:))))) / meanX;
        cc  = corrcoef(data(:),max(0,compared_data(:)));
        cc  = cc(1,2);
    end

    ratio = space / (width*height*num_frames*ele_size);

    fprintf('%f, %f, %f, %f', mse, mae, cc, ratio);


    if DEBUG_WRITE == 1
        dlmwrite('tmp.txt', [find(M==0), data(~M), max(0,compared_data(~M))]);
    end
        
end



function [w2s, h2s] = find_block_ind(w, h, num_blocks, blocks)
    % fprintf('find block ind: w=%d, h=%d, nw=%d, nh=%d, blocks=%d', w, h, num_blocks, blocks);
    
    if blocks == -1
        w2s = [1:num_blocks(2)];
        h2s = [1:num_blocks(1)];
        return;
    else
        if blocks >= 0
            w2s = [w];
            h2s = [h];
        end

        if blocks >= 1
            if w > 1
                w2s = [w2s, w-1];
                h2s = [h2s, h];
            end
        end

        if blocks >= 2
            if h < num_blocks(1)
                w2s = [w2s, w];
                h2s = [h2s, h+1];
            end
        end

        if blocks >= 3
            if w < num_blocks(2)
                w2s = [w2s, w+1];
                h2s = [h2s, h];
            end
        end

        if blocks >= 4
            if h > 1
                w2s = [w2s, w];
                h2s = [h2s, h-1];
            end
        end

        if blocks >= 5
            if w > 1 & h < num_blocks(1)
                w2s = [w2s, w-1];
                h2s = [h2s, h+1];
            end
        end

        if blocks >= 6
            if w < num_blocks(2) & h < num_blocks(1)
                w2s = [w2s, w+1];
                h2s = [h2s, h+1];
            end
        end

        if blocks >= 7
            if w < num_blocks(2) & h > 1
                w2s = [w2s, w+1];
                h2s = [h2s, h-1];
            end
        end

        if blocks >= 8
            if w > 1 & h > 1
                w2s = [w2s, w-1];
                h2s = [h2s, h-1];
            end
        end
    end
end


%% -------------------------------------
%% map_matrix: swap row and columns according to "mapping"
%% @input mapping: 
%%    a vector to map venues to the other
%%    e.g. [4, 3, 1, 2] means mapping 1->4, 2->3, 3->1, 4->2
%%
function [new_mat] = map_matrix(mat, mapping_rows, mapping_cols)
    new_mat = zeros(size(mat));
    new_mat(mapping_rows, :) = mat;
    tmp = new_mat;
    new_mat(:, mapping_cols) = tmp;
end



%% find_ind: function description
% function [map_ind] = find_mapping_ind(ind, width, height, mapping)
%     y = mod(ind-1, height) + 1;
%     x = floor((ind-1)/height) + 1;

%     x2 = mapping(x);
%     y2 = mapping(y);
%     map_ind = (x2 - 1) * height + y2;
% end


%% -------------------------------------
%% sort_by_lat_lng
%% @input location: 
%%    a Nx2 matrix to represent the (lat, lng) of N venues
%%
% function [mapping] = sort_by_lat_lng(location, width, height)
%     mapping = ones(1, width);
%     tmp = 2:width;
%     src = 1;
%     src_ind = 2;
%     while length(tmp) > 0
%         min_dist = -1;
%         min_dist_dst = 0;
%         min_dist_ind = 0;

%         ind = 0;
%         for dst = tmp
%             ind = ind + 1;
%             dist = pos2dist(location(src,1), location(src,2), location(dst,1), location(dst,2), 2);

%             if (min_dist == -1) | (min_dist > dist) 
%                 min_dist = dist;
%                 min_dist_dst = dst;
%                 min_dist_ind = ind;
%             end
%         end

%         if tmp(min_dist_ind) ~= min_dist_dst
%             fprintf('min dist dst does not match: %d, %d\n', tmp(min_dist_ind), min_dist_dst);
%             return;
%         end

%         mapping(src_ind) = min_dist_dst;
%         src = min_dist_dst;
%         src_ind = src_ind + 1;
%         tmp(min_dist_ind) = [];
%     end
% end


%% -------------------------------------
%% sort_by_coef
%% @input coef: 
%%    a NxN matrix to represent the correlation coefficient of N venues
%%
function [mapping] = sort_by_coef(coef)
    sx = size(coef, 1);
    mapping = ones(1, sx);
    tmp = 2:sx;  %% list of non-selected venues
    src = 1;
    src_ind = 2; %% index to mpaaing
    while length(tmp) > 0
        max_coef = -1;
        max_coef_dst = 0;
        max_coef_ind = 0;

        ind = 0;  %% index to tmp
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
            error('exit');
        end

        mapping(src_ind) = max_coef_dst;
        src = max_coef_dst;
        src_ind = src_ind + 1;
        tmp(max_coef_ind) = [];
    end
end


%% first_guess: fill in the missing elements
function [filled_data] = first_guess(method, data, M)
    filled_data = data;
    filled_data(~M) = 0;

    sx = size(data);
    nx = sx(1) * sx(2) * sx(3);
    nx_f = sx(1) * sx(2);


    if strcmp(method, 'avg') == 1
        
        for drop = [find(M == 0)]
            tmp_sum = 0;
            tmp_cnt = 0;

            if (drop + 1 < nx) & (M(drop+1) == 1)
                tmp_sum = tmp_sum + data(drop+1);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop + nx_f < nx) & (M(drop+nx_f) == 1)
                tmp_sum = tmp_sum + data(drop+nx_f);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop + 2*nx_f < nx) & (M(drop+2*nx_f) == 1)
                tmp_sum = tmp_sum + data(drop+2*nx_f);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop - 1 > 0) & (M(drop-1) == 1)
                tmp_sum = tmp_sum + data(drop-1);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop - nx_f > 0) & (M(drop-nx_f) == 1)
                tmp_sum = tmp_sum + data(drop-nx_f);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop - 2*nx_f > 0) & (M(drop-2*nx_f) == 1)
                tmp_sum = tmp_sum + data(drop-2*nx_f);
                tmp_cnt = tmp_cnt + 1;
            end

            if tmp_cnt > 0
                filled_data(drop) = tmp_sum / tmp_cnt;
            end
        end
    
    else
        error('wrong input metho: %d\n', method);
    end
end

