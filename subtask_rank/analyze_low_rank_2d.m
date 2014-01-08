%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.10 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%   [sigma] = analyze_low_rank_2d('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 100, 23, 23, 0.01);
%%   [sigma] = analyze_low_rank_2d('../condor_data/abilene/', 'X', 100, 121, 1, 0.01);
%%   [sigma] = analyze_low_rank_2d('../condor_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.006.bin10.sub.', 100, 21, 26, 0.01);
%%   [sigma] = analyze_low_rank_2d('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_upload.sjtu_wifi.ap_load.600.txt', 100, 250, 1, 0.01);
%%   [sigma] = analyze_low_rank_2d('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sjtu_wifi.ap_load.600.txt', 100, 250, 1, 0.01);
%%   [sigma] = analyze_low_rank_2d('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs1.all.bin10.txt', 100, 458, 1, 0.01);
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sigma] = analyze_low_rank_2d(input_TM_dir, filename, num_frames, width, height, thresh)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;


    %% --------------------
    %% Variable
    %% --------------------
    output_dir = '../processed_data/subtask_rank/rank_2d/';


    %% --------------------
    %% Main starts
    %% --------------------
    % rand('seed', seed);
    

    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    if strcmpi(filename, 'X') | ...
       strcmpi(filename, 'tm_upload.sjtu_wifi.ap_load.600.txt') | ...
       strcmpi(filename, 'tm_download.sjtu_wifi.ap_load.600.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs0.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs1.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs2.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs4.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs5.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs6.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs7.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs8.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs9.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs10.all.bin10.txt') | ...
       strcmpi(filename, 'tm_3g.cell.bs.bs11.all.bin10.txt')
        %% load data matrix
        data = zeros(height, width, num_frames);

        this_matrix_file = [input_TM_dir filename];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file)';
        data(:, :, :) = tmp(:, 1:num_frames);

    else
        data = zeros(height, width, num_frames);
        for frame = [0:num_frames-1]
            if DEBUG0, fprintf('  frame %d\n', frame); end

            %% load data matrix
            this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
            if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
            
            tmp = load(this_matrix_file);
            data(:,:,frame+1) = tmp(1:height, 1:width);
        end
    end
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% Convert to 2D
    %% --------------------
    if DEBUG2, fprintf('Convert to 2D\n'); end
    
    orig_sx = size(data);
    data = reshape(data, orig_sx(1) * orig_sx(2), orig_sx(3));
    

    %% --------------------
    %% calculate the rank
    %% --------------------
    if DEBUG2, fprintf('calculate the rank\n'); end

    m = data;
    m = m - mean(m(:));
    sigma = svd(m);

    total_sum = sum(sigma);
    total_sum_sofar = cumsum(sigma);
    cdf = total_sum_sofar ./ total_sum;

    %% change point
    inv_singular = [1; 1 - cdf];
    ix = find(inv_singular < thresh);
    if length(ix) > 0
        r = ix(1);
    else
        r = length(sigma);
    end

    output_file = [output_dir filename '.rank.txt'];
    dlmwrite(output_file, inv_singular, 'delimiter', '\t');

    fprintf('rand = %d\n', r);


    %% --------------------
    %% remove the top-rank nodes
    %% --------------------
    if DEBUG2, fprintf('remove the top-loaded nodes\n'); end

    
    
end






