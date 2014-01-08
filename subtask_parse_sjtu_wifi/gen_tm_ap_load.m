%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.01.05 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gen_tm_ap_load()
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '../processed_data/subtask_parse_sjtu_wifi/tm/';
    output_dir = '../processed_data/subtask_parse_sjtu_wifi/tm/';

    filename_ul = 'tm_upload.sort_ips.ap.country.txt.600.';
    filename_dl = 'tm_download.sort_ips.ap.country.txt.600.';
    nf     = 114;
    num_ap = 250;


    %% --------------------
    %% Check input
    %% --------------------


    %% --------------------
    %% Main starts
    %% --------------------
    data_ul = zeros(num_ap, nf);
    data_dl = zeros(num_ap, nf);
    for f = 1:nf
        fprintf('frame %d\n', f);

        %% uplink
        tmp = load([input_dir filename_ul int2str(f-1) '.txt']);
        tmp = sum(tmp, 2);
        fprintf('  UL: %d, %d\n', size(tmp));
        data_ul(:, f) = tmp;

        %% downlink
        tmp = load([input_dir filename_dl int2str(f-1) '.txt']);
        tmp = sum(tmp, 1)';
        fprintf('  DL: %d, %d\n', size(tmp));
        data_dl(:, f) = tmp;
    end

    dlmwrite([output_dir 'tm_upload.sjtu_wifi.ap_load.600.txt'], data_ul', 'delimiter', '\t');
    dlmwrite([output_dir 'tm_download.sjtu_wifi.ap_load.600.txt'], data_dl', 'delimiter', '\t');

end