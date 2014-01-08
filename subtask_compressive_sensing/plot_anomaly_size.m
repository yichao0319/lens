%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.01.05 @ UT Austin
%%
%% - Input:
%%
%% - Output:
%%
%% e.g. 
%%     plot_anomaly_size('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 8, 217, 400)
%%     plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.006.bin10.sub.', 145, 21, 26)
%%     plot_anomaly_size('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 600, 23, 23)
%%     plot_anomaly_size('../condor_data/abilene/', 'X', 600, 121, 1)
%%     plot_anomaly_size('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_upload.sjtu_wifi.ap_load.600.txt', 110, 250, 1)
%%     plot_anomaly_size('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sjtu_wifi.ap_load.600.txt', 110, 250, 1)
%%     plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs6.all.bin10.txt', 144, 240, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_anomaly_size(input_TM_dir, filename, num_frames, width, height)
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0; %% block index check
    
    % if width ~= height
    %     fprintf('width should be equal to height: %d, %d\n', width, height);
    %     return;
    % end


    %% --------------------
    %% Constant
    %% --------------------
    

    %% --------------------
    %% Variable
    %% --------------------
    

    %% --------------------
    %% Main starts
    %% --------------------
    
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
    %% Add anomaly
    %% --------------------
    if DEBUG2, fprintf('Add anomaly and noise\n'); end

    tmp_sx = size(data);
    data = reshape(data, [], tmp_sx(3));
    [n, m] = size(data);

    itvl = 20;
    anom_mags = [0.2, 0.4, 0.6, 0.8, 1];
    anom_ix   = [1:length(anom_mags)] * itvl

    % data = data(:,10:end);
    max_data = max(data(:));
    fprintf('  max anomaly = %f, itvl = %d\n', max_data, itvl);
    anomaly   = sign(rand(1, length(anom_mags))) * max_data .* anom_mags;

    % noise = randn(n, m) * max_data * 0.01;
    

    %% --------------------
    %% plot for total traffic
    %% --------------------
    if DEBUG2, fprintf('plot for total traffic\n'); end

    orig_total_ts = sum(data);
    anom_total_ts = orig_total_ts;
    anom_total_ts(anom_ix) = anom_total_ts(anom_ix) + anomaly;
    % noise_total_ts = sum(data + noise);
    
    % plot_my([1:length(orig_total_ts)], ...
    %         [anom_total_ts; orig_total_ts], ...
    %         {'w/ anomaly', 'orig'}, ...
    %         ['./tmp_output/' filename '.total.png'], ...
    %         'time', 'traffic');
    plot_my([1:length(orig_total_ts)], ...
            [orig_total_ts], ...
            {'orig'}, ...
            ['./tmp_output/' filename '.total.png'], ...
            'time', 'traffic');
    dlmwrite('./tmp_output/total_ts.txt', orig_total_ts, 'delimiter', '\n');
    


    %% --------------------
    %% plot for one OD pair
    %% --------------------
    if DEBUG2, fprintf('plot for one OD pair\n'); end

    
    [c, ix] = max(data(:));
    sx = size(data);
    [a,b] = ind2sub(sx, ix(1));

    orig_one_ts = data(a, :);
    anom_one_ts = orig_one_ts;
    anom_one_ts(anom_ix) = anom_one_ts(anom_ix) + anomaly;
    % noise_one_ts = data(a, :) + noise(a, :);
    
    % plot_my([1:length(orig_one_ts)], ...
    %         [anom_one_ts; orig_one_ts], ...
    %         {'anomaly', 'orig ts'}, ...
    %         ['./tmp_output/' filename '.one.png'], ...
    %         'time', 'traffic');
    plot_my([1:length(orig_one_ts)], ...
            [orig_one_ts], ...
            {'orig ts'}, ...
            ['./tmp_output/' filename '.one.png'], ...
            'time', 'traffic');
    dlmwrite('./tmp_output/single_ts.txt', orig_one_ts, 'delimiter', '\n');
    
end





function plot_my(x, y, legends, file, x_label, y_label)

    colors  = {'r','b','g','c','m','y','k'};
    markers = {'+','o','*','.','x','s','d','^','>','<','p','h'};
    lines   = {'-','-','-','-.'};
    font_size = 18;
    cnt = 1;

    clf;
    fh = figure;
    hold all;

    lh = zeros(1, size(y, 1));
    for yi = 1:size(y, 1)
        yy = y(yi, :);

        %% line
        lh(yi) = plot(x, yy);
        set(lh(yi), 'Color', char(colors(mod(cnt-1,length(lines))+1)));      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
        set(lh(yi), 'LineStyle', char(lines(mod(cnt-1,length(lines))+1)));
        set(lh(yi), 'LineWidth', 3);
        % if yi==1, set(lh(yi), 'LineWidth', 1); end
        % set(lh(yi), 'marker', char(markers(mod(cnt-1,length(markers))+1)));
        % set(lh(yi), 'MarkerEdgeColor', 'auto');
        % set(lh(yi), 'MarkerFaceColor', 'auto');
        % set(lh(yi), 'MarkerSize', 12);

        cnt = cnt + 1;
    end

    set(gca, 'XTick', [0:20:140]);

    set(gca, 'FontSize', font_size);
    set(fh, 'PaperUnits', 'points');
    set(fh, 'PaperPosition', [0 0 1024 300]);

    xlabel(x_label, 'FontSize', font_size);
    ylabel(y_label, 'FontSize', font_size);

    % kh = legend(legends);
    % set(kh, 'Box', 'off');
    % set(kh, 'Location', 'BestOutside');
    % set(kh, 'Orientation', 'horizontal');
    % set(kh, 'Position', [.1,.2,.1,.2]);

    grid on;

    print(fh, '-dpng', [file '.png']);
end
