%% --------------------
% 2013/09/24
% Yi-Chao Chen @ UT Austin
%
% PCA_psnr_by_frame
% 
% @input (optional) num_PC: num of PCs to use (i.e. rank)
% @input (optional) dct_thresh: when the value after DCT <= dct_thresh, make it 0
% @input (optional) video_name: the name of raw video (assume the video format: YUV CIF 4:2:0)
% @input (optional) frames: number of frames to analyze
% @input (optional) width: the width of the video
% @input (optional) height: the height of the video
%
% note
% - stefan_cif.yuv
%   CIF, YCbCr 4:2:0 planar 8 bit, 352*288, 90 frames
% - bus_cif.yuv
%   CIF, YCbCr 4:2:0 planar 8 bit, 352*288, 150 frames
%
%% --------------------

function [psnr, compressed_ratio] = PCA_psnr(num_PC, dct_thresh, video_name, frames, width, height)
    addpath('../utils/YUV2Image');
    addpath('../utils/mirt_dctn');
    addpath('../utils');

    %% --------------------
    % Debugs
    %% --------------------
    DEBUG0 = 0;     %% don't print 
    DEBUG1 = 1;     %% print 
    DEBUG2 = 0;     %% program flow
    DEBUG3 = 0;     %% output


    %% --------------------
    % Input
    %% --------------------
    if nargin == 2
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    elseif nargin == 6
        video.file = video_name;
        video.frames = frames;
        video.width = width;
        video.height = height;
    else
        num_PC = 288;
        dct_thresh = 0;
        video.file = 'stefan_cif.yuv';
        video.frames = 90;  %% 90
        video.width = 352;
        video.height = 288;
    end


    %% --------------------
    % Variables
    %% --------------------
    input_dir = '../data/video/';
    

    %% --------------------
    % Main starts here
    %% --------------------
    if DEBUG2 == 1
        fprintf('start to load video: %s\n', [input_dir, video.file]);
    end

    mov = loadFileYuv([input_dir, video.file], video.width, video.height, 1:video.frames);
    if DEBUG2 == 1
        fprintf('  done loading.\n');
    end


    %% --------------------
    %  Loop over the frames
    %% --------------------
    compressed_size = 0;
    for k = 1:video.frames  
        % [h, w, p] = size(mov(k).cdata);
        imgYuv = mov(k).imgYuv;
        [h, w, p] = size(imgYuv);

        if DEBUG0 == 1
            fprintf('frame %d: w=%d, h=%d, p=%d\n', k, w, h, p);
        end


        raw_video_vector_y(:, :) = imgYuv(:,:,1);
        raw_video_vector_u(:, :) = imgYuv(:,:,2);
        raw_video_vector_v(:, :) = imgYuv(:,:,3);

        
        %% --------------------
        %  DCT
        %% --------------------
        raw_video_vector_y = mirt_dctn(raw_video_vector_y);
        raw_video_vector_u = mirt_dctn(raw_video_vector_u);
        raw_video_vector_v = mirt_dctn(raw_video_vector_v);


        %% --------------------
        %  values after DCT < dct_thresh, make them 0
        %% --------------------
        raw_video_vector_y(abs(raw_video_vector_y) < dct_thresh) = 0;
        raw_video_vector_u(abs(raw_video_vector_u) < dct_thresh) = 0;
        raw_video_vector_v(abs(raw_video_vector_v) < dct_thresh) = 0;



        rank_y = min(rank(raw_video_vector_y), num_PC);
        rank_u = min(rank(raw_video_vector_u), num_PC);
        rank_v = min(rank(raw_video_vector_v), num_PC);

        if DEBUG0
            fprintf('  rank = (%d, %d, %d)\n', rank_y, rank_u, rank_v);
        end


        %% --------------------
        %  PCA
        %% --------------------
        [latent_y, U_y, eigenvector_y] = calculate_PCA(raw_video_vector_y);
        [latent_u, U_u, eigenvector_u] = calculate_PCA(raw_video_vector_u);
        [latent_v, U_v, eigenvector_v] = calculate_PCA(raw_video_vector_v);


        %% --------------------
        %  Compressed video:
        %% --------------------
        compressed_video_vector_y = PCA_compress(latent_y, U_y, eigenvector_y, rank_y);
        compressed_video_vector_u = PCA_compress(latent_u, U_u, eigenvector_u, rank_u);
        compressed_video_vector_v = PCA_compress(latent_v, U_v, eigenvector_v, rank_v);
        compressed_size = compressed_size + (1 + w + h) * (rank_y + rank_u + rank_v);


        %% --------------------
        %  Inverse DCT
        %% --------------------
        compressed_video_vector_y = mirt_idctn(compressed_video_vector_y);
        compressed_video_vector_u = mirt_idctn(compressed_video_vector_u);
        compressed_video_vector_v = mirt_idctn(compressed_video_vector_v);


        compressed_mov(k).imgYuv(:,:,1) = compressed_video_vector_y;
        compressed_mov(k).imgYuv(:,:,2) = compressed_video_vector_u;
        compressed_mov(k).imgYuv(:,:,3) = compressed_video_vector_v;

    end %% end for all frames

    %% --------------------
    %  PSNR
    %% --------------------
    psnr = calculate_psnr(mov, compressed_mov, video.frames);
    original_size = video.frames * video.width * video.height * 3;
    compressed_ratio = compressed_size / original_size;

    if DEBUG3 == 1
        fprintf('size=%d/%d=%f, PSNR=%f\n', compressed_size, original_size, compressed_ratio, psnr);
    end


end

