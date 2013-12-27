%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.26 @ UT Austin
%%
%% - Input:
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      'org': original matrix
%%      'rand': randomize raw and col
%%      'geo': geo -- can only be used by 4sq TM matrix
%%      'cc': correlation coefficient
%%   @option_type: determine the type of estimation
%%      'base': baseline alg
%%      'srmf'
%%      'srmf_knn'
%%      'svd'
%%      'svd_base'
%%      'lens'
%%      'nmf'
%%   @option_dim: the dimension of the input matrix
%%      '2d': convert to 2D
%%      '3d': the original tm is 3D
%%   @drop_ele_mode:
%%      'elem': drop elements
%%      'row': drop rows
%%      'col': drop columns
%%   @drop_mode:
%%      'ind': drop independently
%%      'syn': rand loss synchronized among elem_list
%%   @elem_frac: 
%%      (0-1): the fraction of elements in a frame 
%%      0    : compression
%%   @loss_rate: 
%%      (0-1): the fraction of frames to drop
%%   @burst_size: 
%%      burst in time (i.e. frame)
%%
%% - Output:
%%
%% e.g. 
%%     [mse, mae, cc, ratio] = srmf_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 8, 217, 400, 4, 5, 'org', 'srmf', '2d', 'elem', 'ind', 0.2, 0.5, 1, 1)
%%     [mse, mae, cc, ratio] = srmf_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.002.bin60.sub.', 24, 120, 100, 24, 5, 'org', 'srmf', '2d','elem', 'ind', 0.4, 1, 1, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc, ratio] = srmf_based_pred(input_TM_dir, filename, num_frames, width, height, group_size, r, option_swap_mat, option_type, option_dim, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, seed)
    addpath('../utils/lens');
    addpath('../utils/mirt_dctn');
    addpath('../utils/compressive_sensing');
    addpath('../utils');


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
    ele_size = 32;  %% size of each elements in bits
    epsilon = 0.01;

    alpha = 100; lambda = 1000000000;
    if strcmpi(filename, 'tm_3g_region_all.res0.002.bin60.sub.')
        alpha = 100; lambda = 1000000000;
    elseif strcmpi(filename, 'tm_3g_region_all.res0.004.bin60.sub.')
        alpha = 1e-5; lambda = 1e-6;
    end


    %% --------------------
    %% Variable
    %% --------------------
    % input_4sq_dir  = '../processed_data/subtask_process_4sq/TM/';
    space = 0;


    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    num_groups = ceil(num_frames / group_size);


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
    %% DEBUG
    %% --------------------
    if DEBUG2, fprintf('debug array\n'); end

    % data = ones(size(data));



    %% --------------------
    %% drop elements
    %% --------------------
    if DEBUG2, fprintf('drop elements\n'); end

    % M = ones(size(data));
    % if loss_rate > 0
    %     %% prediction
    %     num_missing = ceil(nx * loss_rate);
    %     for f = [1:num_frames]
    %         if DEBUG0, fprintf('  frame %d\n', f); end

    %         ind = randperm(nx);
    %         tmp = M(:,:,f);
    %         tmp(ind(1:num_missing)) = 0;
    %         M(:,:,f) = tmp;
    %     end
    % else
    %     %% compression
    % end
    if elem_frac > 0
        %% prediction
        M = DropValues(sx(1), sx(2), num_frames, elem_frac, loss_rate, drop_ele_mode, drop_mode, burst_size);
    else
        %% compression
        M = ones(size(data));
    end


    %% --------------------
    %% swap matrix row and column
    %% 0: original matrix
    %% 1: randomize raw and col
    %% 2: geo
    %% 3: correlated coefficient
    %% --------------------
    if DEBUG2, fprintf('swap matrix row and column\n'); end

    if strcmp(option_swap_mat, 'org')
        %% 0: original matrix
        mapping_rows = [1:height];
        mapping_cols = [1:width];
    elseif strcmp(option_swap_mat, 'rand')
        %% 1: randomize raw and col
        mapping_rows = randperm(height);
        mapping_cols = randperm(width);
    elseif strcmp(option_swap_mat, 'geo')
        %% 2: geo -- only for 4sq TM
        % [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
        % if DEBUG0
        %     fprintf('  size of location: %d, %d\n', size(location));
        %     fprintf('  size of mass: %d, %d\n', size(mass));
        % end
        
        % mapping = sort_by_lat_lng(location, width, height);

    elseif strcmp(option_swap_mat, 'cc')
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

    elseif strcmp(option_swap_mat, 'pop')
        %% 4: popularity
        error('swap according to popularity: not done yet\n');
        
    end

    %% update the data matrix according to the mapping
    for f = [1:num_frames]
        data(:,:,f) = map_matrix(data(:,:,f), mapping_rows, mapping_cols);
        M(:,:,f)    = map_matrix(M(:,:,f), mapping_rows, mapping_cols);
    end

    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end


    compared_data = data;
    compared_data(~M) = 0;

    %% --------------------
    %% apply SRMF to each Group of Pictures (GoP)
    %% --------------------
    for gop = 1:num_groups
        gop_s = (gop - 1) * group_size + 1;
        gop_e = min(num_frames, gop * group_size);

        if DEBUG1 == 0, fprintf('gop %d: frame %d-%d\n', gop, gop_s, gop_e); end

        this_group   = data(:, :, gop_s:gop_e);
        this_group_M = M(:, :, gop_s:gop_e);


        %% --------------------
        %% convert to 2D
        %% --------------------
        if strcmpi(option_dim, '2d')
            orig_sx = size(this_group);
            % fprintf('size: %d\n',orig_sx);
            this_group = reshape(this_group, [], orig_sx(3));
            this_group_M = reshape(this_group_M, [], orig_sx(3));
            % size(this_group)
        end



        %% --------------------
        %  Compressive Sensing
        %% --------------------
        this_rank = r; %min(r, rank(this_group));
        

        % meanX2 = mean(this_group(:).^2);
        % meanX = mean(this_group(:));
        sx = size(this_group);
        nx = prod(sx);
        n  = length(sx);

        [A, b] = XM2Ab(this_group, this_group_M);

        if strcmpi(option_type, 'base')
            %% baseline
            est_group = EstimateBaseline(A, b, sx);

            %% space
            space = space + (prod(size(A)) + prod(size(b))) * ele_size;

        elseif strcmpi(option_type, 'srtf')
            %% SRMF
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true);
            % [u4, v4, w4] = SRTF(this_group, this_rank, this_group_M, config, 10, 1e-1, 50);
            [u4, v4, w4] = SRTF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);

            est_group = tensorprod(u4, v4, w4);
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) + prod(size(w4))) * ele_size;

        elseif strcmpi(option_type, 'srmf')
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true);

            [u4, v4] = SRMF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) ) * ele_size;

        elseif strcmpi(option_type, 'srtf_knn')
            %% SRMF + KNN
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true);
            [u4, v4, w4] = SRTF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);

            est_group = tensorprod(u4, v4, w4);
            est_group = max(0, est_group);

            if strcmpi(option_dim, '3d')
                orig_f = reshape(this_group, [], sx(n))';
                est_f = reshape(est_group, [], sx(n))';
                Z = est_f;
                f_M   = reshape(this_group_M, [], sx(n))';
                % size(est_f)
                
                maxDist = 3;
                EPS = 1e-3;
                
                for i = 1:group_size
                    for j = find(f_M(i,:) == 0)
                        ind = find((f_M(i,:)==1) & (abs((1:(sx(1)*sx(2))) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_f(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_f(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(orig_f(i,ind).*w);
                        end
                    end
                end
                est_group = reshape(Z', sx(1), sx(2), sx(3));
            elseif strcmpi(option_dim, '2d')
                Z = est_group;

                maxDist = 3;
                EPS = 1e-3;
                
                for i = 1:size(Z,1)
                    for j = find(this_group_M(i,:) == 0);
                        ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_group(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_group(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(this_group(i,ind).*w);
                        end
                    end
                end
                est_group = Z;
            else
                error('wrong option_dim');
            end
                

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) + prod(size(w4))) * ele_size;

        elseif strcmpi(option_type, 'srmf_knn')
            %% SRMF + KNN
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true);
            [u4, v4] = SRMF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            if strcmpi(option_dim, '3d')
                orig_f = reshape(this_group, [], sx(n))';
                est_f = reshape(est_group, [], sx(n))';
                Z = est_f;
                f_M   = reshape(this_group_M, [], sx(n))';
                % size(est_f)
                
                maxDist = 3;
                EPS = 1e-3;
                
                for i = 1:group_size
                    for j = find(f_M(i,:) == 0)
                        ind = find((f_M(i,:)==1) & (abs((1:(sx(1)*sx(2))) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_f(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_f(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(orig_f(i,ind).*w);
                        end
                    end
                end
                est_group = reshape(Z', sx(1), sx(2), sx(3));
            elseif strcmpi(option_dim, '2d')
                Z = est_group;

                maxDist = 3;
                EPS = 1e-3;


                for i = 1:size(Z,1)
                    for j = find(this_group_M(i,:) == 0);
                        ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_group(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_group(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(this_group(i,ind).*w);
                        end
                    end
                end
                
                est_group = Z;
            else
                error('wrong option_dim');
            end
                

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) ) * ele_size;

        elseif strcmpi(option_type, 'lens')
            %% lens
            A = eye(size(this_group, 1));
            B = eye(size(this_group, 1));
            C = eye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = 0.1;
            F = ones(size(this_group));

            [X,Y,Z,W,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            
            r = min(this_rank, rank(X));
            F = (Y~=0);

            soft = 0;
            [X, Y, Z, W] = lens(this_group, r, A,B,C, E,F, sigma, soft);
            est_group = A*X + B*(Y.*F) + Z + E.*W;


            %% space
            space = space + prod(size(this_group));

        elseif strcmpi(option_type, 'svd')
            %% svd
            [u,v,w] = FactTensorACLS(this_group, this_rank, this_group_M, false, epsilon, 50, 1e-8, 0);
            
            est_group = tensorprod(u,v,w);
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;

        elseif strcmpi(option_type, 'svd_base')
            %% svd_base
            BaseX = EstimateBaseline(A, b, sx);
            [u,v,w] = FactTensorACLS(this_group-BaseX, this_rank, this_group_M, false, epsilon, 50, 1e-8, 0);

            est_group = tensorprod(u,v,w) + BaseX;
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;

            tmp = this_group - est_group;
            fprintf('mean=%f\n', mean(tmp(:)) );

        elseif strcmpi(option_type, 'nmf')
            %% nmf
            [u,v,w] = ntf(this_group, this_rank, this_group_M, 'L2', 200, epsilon);
            est_group = tensorprod(u,v,w);
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;
        else
            error('wrong option type');
        end
        

        if strcmpi(option_dim, '3d')
            compared_data(:, :, gop_s:gop_e) = est_group;
        elseif strcmpi(option_dim, '2d')
            compared_data(:, :, gop_s:gop_e) = reshape(est_group, orig_sx);
        else
            error('wrong option_dim');
        end


        tmp = abs(compared_data - data);
        fprintf('mean=%f\n', mean(tmp(:)) );
    end


    meanX2 = mean(data(~M).^2);
    meanX = mean(data(~M));

    if elem_frac > 0
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

    fprintf('results=%f, %f, %f, %f\n', mse, mae, cc, ratio);


    missing = data(~M);
    pred    = compared_data(~M);
    % size(missing)
    % nnz(missing)
    ix = find(missing > 0);
    missing(ix(1:min(10,length(ix))))'
    pred(ix(1:min(10,length(ix))))'


    if DEBUG_WRITE == 1
        dlmwrite('tmp.txt', [find(M==0), data(~M), max(0,compared_data(~M))]);
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
