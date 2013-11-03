%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.26 @ UT Austin
%%
%% - Input:
%%   @option_dect: options to do anomaly detection
%%      1: use original values
%%      2: replace anomaly by approximated value
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      0: original matrix
%%      1: randomize raw and col
%%      2: geo
%%      3: correlated coefficient
%%
%% - Output:
%%
%% e.g. 
%%     [mse, mae, cc] = pca_based_pred('../processed_data/subtask_process_4sq/TM/', 'TM_Airport_period5_', 12, 300, 300, 30, 30, 50, 2, 0, 0.001, 1)
%%     [mse, mae, cc] = pca_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm.sort_ips.ap.country.txt.3600.', 8, 346, 346, 100, 100, 50, 2, 0, 0.001, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc] = pca_based_pred(input_TM_dir, filename, num_frames, width, height, block_width, block_height, r, option_dect, option_swap_mat, loss_rate, seed)
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
    % input_TM_dir   = '../processed_data/subtask_process_4sq/TM/';
    % input_TM_dir   = '../processed_data/subtask_inject_error/TM_err/';
    input_errs_dir =  '../processed_data/subtask_inject_error/errs/';
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
    num_missing = ceil(nx * loss_rate);
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
        %% 2: geo
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
    %% pca for each block
    %% --------------------
    if DEBUG2, fprintf('pca for each block\n'); end

    for frame = [1:num_frames]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        for w = [1:num_blocks(1)]
            w_s = (w-1)*block_width + 1;
            w_e = min(w*block_width, width);
            for h = [1:num_blocks(2)]
                h_s = (h-1)*block_height + 1;
                h_e = min(h*block_height, height);
                if DEBUG3, fprintf('  block: [%d,%d]\n', w, h); end
                
                this_block   = data(w_s:w_e, h_s:h_e, frame);
                this_block_M = M(w_s:w_e, h_s:h_e, frame);

                %% first guess of missing elements
                this_block(~this_block_M) = mean(reshape(this_block(this_block_M==1), [], 1));
                
                %% ------------
                %% PCA of this block
                this_rank = min(r, rank(this_block));
                [latent, U, eigenvector] = calculate_PCA(this_block);
                compared_data(w_s:w_e, h_s:h_e, frame) = PCA_compress(latent, U, eigenvector, this_rank);
            end
        end
    end


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