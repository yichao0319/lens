%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
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

% function pred_tomography(num_anom, sigma_mag)
function pred_tomography()
    addpath('/u/yichao/anomaly_compression/utils/lens');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
    addpath('/u/yichao/anomaly_compression/utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '/u/yichao/anomaly_compression/condor_data/abilene/';
    
    r0 = 8;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;

    sigma_mag = 0;  %% anomaly size
    num_anom = 0.05;     %% ratio of anomalies
    sigma_noise = 0; %% noise size


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------


    %% --------------------
    %% load data
    %% --------------------
    X = load([input_dir 'X']); %% 1008x121
    A = load([input_dir 'A']); %% 41x121


    %% --------------------
    %% add anomalies
    %% --------------------
    [n,m] = size(X);
    ny = floor(n*m*num_anom);;
    Y = sparse(n, m);
    Y(randsample(n*m, ny)) = sign(randn(ny, 1)) * max(X(:)) * sigma_mag;

    %% --------------------
    %% add noise
    %% --------------------
    Z = randn(n, m) * max(X(:)) * sigma_noise;
    X = max(0, X + Y + Z);

    % D = load([input_dir 'Y']); %% 1008x41
    D = (A * X')';
    

    %% --------------------
    %% transpose matrices as required in codes and mean centered
    %% --------------------
    X = X' / mean(mean(D));
    D = D' / mean(mean(D));
    % fprintf('D - AX = %f\n', sum(sum(abs(D - A * X))) );


    %% --------------------
    %% Drop TM elements
    %% --------------------
    % loss_rate = 0.95;
    % E = rand(size(X)) < loss_rate;
    % M = ~E;
    % fprintf('loss rate = %f\n', nnz(E) / prod(size(E)));


    %% ====================================
    %% LENS_ST
    % fprintf('=======================\nLENS_ST\n');
    r = r0;
    [n,m] = size(D);
    E = zeros(size(D));
    B = speye(n,n);
    C = speye(n,n);
    F = ones(n,m);
    soft = 1;
    [x,y,z,w,u,v,s,t,sigma] = lens_st(D,r,A,B,C,E,F,[],soft);
    est = max(x, 0);
    mae = sum(abs(est-X)) / sum(abs(X));
    fprintf('=> mae=%f\n', mae);

    % est(1:10, 1:10)
    % X(1:10, 1:10)


    % %% ====================================
    % %% SRMF
    % fprintf('=======================\nSRMF\n');
    % r = r0;
    % sx = size(X);
    % [A, b] = XM2Ab(X, M);
    % size(A)
    % size(b)
    % return;
    % config = ConfigSRTF(A, D, X, M, sx, r, r, epsilon, true);
    % [u4, v4] = SRMF(D, r, M, config, alpha, lambda, 50);
    % est = u4 * v4';
    % size(est)



end