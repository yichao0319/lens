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

function batch_srmf_based_pred()
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    % tm_dir  = '../processed_data/subtask_parse_totem/tm/';
    % tm_name = 'tm_totem.';
    % nf      = 100;
    % nw      = 23;
    % nh      = 23;
    % gop     = 100;
    % r       = 10;
    tm_dir  = '../condor_data/abilene/';
    tm_name = 'X';
    nf      = 100;
    nw      = 121;
    nh      = 1;
    gop     = 100;
    r       = 10;
    % tm_dir  = '../condor_data/subtask_parse_huawei_3g/region_tm/';
    % tm_name = 'tm_3g_region_all.res0.006.bin10.sub.';
    % nf      = 100;
    % nw      = 21;
    % nh      = 26;
    % gop     = 100;
    % r       = 10;


    order     = 'rand';
    thresh    = 0.2;
    sigma_mag = 0
    noise     = 0
    loss_rate = 0.2
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.4
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.6
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.8
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.9
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.95
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.98
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    sigma_mag = 0.2
    noise     = 0.001
    loss_rate = 0.2
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.4
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.6
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.8
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.9
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.95
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.98
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % sigma_mag = 0.4
    % noise = 0.001
    
    % loss_rate = 0.6
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % sigma_mag = 0.6
    % noise = 0.001
    
    % loss_rate = 0.6
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % sigma_mag = 0.8
    % noise = 0.001
    
    % loss_rate = 0.6
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    sigma_mag = 1
    noise = 0.001
    loss_rate = 0.2
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 3); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 3); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.4
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 2); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 2); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.6
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.8
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.9
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.93
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.95
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.96
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.97
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.98
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

    loss_rate = 0.99
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'lens_knn2', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, 0.001, thresh, 1); 
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, order, 'srmf_lens_knn', '2d','elem', 'ind', 1, loss_rate, 1, sigma_mag, noise, thresh, 1); 

end












