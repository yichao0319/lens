%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.18 @ UT Austin
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

function batch_srmf_based_pred2()
    addpath('../utils');

    loss_rates   = [0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99];
    sigma_mags   = [0 0.2 0.4 0.6 0.8 1];
    sigma_noises = [0 0   0   0   0   0];
    schemes      = {'srmf_knn', 'lens_knn2', 'srmf_lens_knn'};
    orders       = {'org'}; %% , 'rand', 'cc', 'pop'
    
    output1 = zeros(length(loss_rates) * length(sigma_mags), 8);
    output2 = zeros(length(loss_rates) * length(sigma_mags), 9*length(schemes));


    % tm_dir  = '../processed_data/subtask_parse_totem/tm/';
    % tm_name = 'tm_totem.';
    % nf      = 100;
    % nw      = 23;
    % nh      = 23;
    % gop     = 100;
    % r       = 10;
    % tm_dir  = '../condor_data/abilene/';
    % tm_name = 'X';
    % nf      = 100;
    % nw      = 121;
    % nh      = 1;
    % gop     = 100;
    % r       = 10;
    % tm_dir  = '../condor_data/subtask_parse_huawei_3g/region_tm/';
    % tm_name = 'tm_3g_region_all.res0.006.bin10.sub.';
    % nf      = 100;
    % nw      = 21;
    % nh      = 26;
    % gop     = 100;
    % r       = 128;
    bs_type = 3;
    tm_dir  = '../processed_data/subtask_parse_huawei_3g/bs_tm/';
    tm_name = ['tm_3g.cell.bs.bs' int2str(bs_type) '.all.bin10.txt'];
    if     bs_type == 0, nw = 1074; r = 64;
    elseif bs_type == 1, nw = 458; r = 64;
    elseif bs_type == 2, nw = 48; r = 16;
    elseif bs_type == 3, nw = 472; r = 64;
    elseif bs_type == 4, nw = 24; r = 16;
    elseif bs_type == 5, continue;
    elseif bs_type == 6, nw = 240; r = 64;
    elseif bs_type == 7, nw = 14; r = 8;
    elseif bs_type == 8, nw = 19; r = 8;
    elseif bs_type == 9, nw = 24; r = 8;
    elseif bs_type == 10, nw = 82; r = 16;
    elseif bs_type == 11, nw = 13; r = 8; 
    nf      = 100;
    nh      = 1;
    gop     = 100;
    % tm_dir  = '../condor_data/subtask_parse_huawei_3g/bs_tm/';
    % tm_name = 'tm_3g.cell.load.top200.all.bin10.txt';
    % nf      = 100;
    % nw      = 200;
    % nh      = 1;
    % gop     = 100;
    % r       = 64;
    % tm_dir  = '../processed_data/subtask_parse_sjtu_wifi/tm/';
    % tm_name = 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt';
    % nf      = 100;
    % nw      = 50;
    % nh      = 1;
    % gop     = 100;
    % r       = 16;


    thresh = -1;
    period = 1;

    for order = orders
        order = char(order);

        for sigma = 1:length(sigma_mags)
            sigma_mag   = sigma_mags(sigma);
            sigma_noise = sigma_noises(sigma);
            fprintf('sigma=%d: anomaly=%f, noise=%f\n', sigma, sigma_mag, sigma_noise);

            for lri = 1:length(loss_rates)
                loss_rate = loss_rates(lri);

                ind = (sigma-1) * length(loss_rates) + lri;
                fprintf('  lri=%d, loss=%f\n', lri, loss_rate);
                fprintf('  ind=%d\n', ind);


                [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'srmf_knn', '2d', 'elem', 'ind', 1, loss_rate, 1, sigma_mag, sigma_noise, thresh, 1);
                output1(ind, [1,4]) = [mse, mae];
                output2(ind, [1,4,7,10,13,16,19,22,25]) = [precision, recall, f1score, jaccard, tp, tn, fp, fn, best_thresh];

                [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens_knn2', '2d', 'elem', 'ind', 1, loss_rate, 1, sigma_mag, sigma_noise, thresh, 1);
                output1(ind, [2,5,7,8]) = [mse, mae, normalized_y, y_val];
                output2(ind, [2,5,8,11,14,17,20,23,26]) = [precision, recall, f1score, jaccard, tp, tn, fp, fn, best_thresh];

                [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'srmf_lens_knn', '2d', 'elem', 'ind', 1, loss_rate, 1, sigma_mag, sigma_noise, thresh, 1); 
                output1(ind, [3,6]) = [mse, mae];
                output2(ind, [3,6,9,12,15,18,21,24,27]) = [precision, recall, f1score, jaccard, tp, tn, fp, fn, best_thresh];

            end
        end

        dlmwrite(['tmp_output/' tm_name '.' order '.pred.txt'], output1, 'delimiter', '\t');
        dlmwrite(['tmp_output/' tm_name '.' order '.dect.txt'], output2, 'delimiter', '\t');
    end
    

end

