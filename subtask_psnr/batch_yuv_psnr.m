input_raw_dir  = '../data/video/';
input_comp_dir = '../processed_data/video/';
output_dir     = '../processed_data/subtask_psnr/mpeg_psnr_output/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Frame + DCT
file_name = 'psnr_frame_dct.txt';
fh = fopen([output_dir file_name], 'w');

for b = [10, 100:100:700]
    % video = 'stefan_cif';
    % psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 90, 352, 288);
    % fprintf('%s, %d, %f\n', video, b, psnr);
    % fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    % video = 'bus_cif';
    % psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 150, 352, 288);
    % fprintf('%s, %d, %f\n', video, b, psnr);
    % fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    % video = 'foreman_cif';
    % psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 300, 352, 288);
    % fprintf('%s, %d, %f\n', video, b, psnr);
    % fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    % video = 'coastguard_cif';
    % psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 300, 352, 288);
    % fprintf('%s, %d, %f\n', video, b, psnr);
    % fprintf(fh, '%s, %d, %f\n', video, b, psnr);

    video = 'highway_cif';
    psnr = yuv_psnr([input_raw_dir video '.yuv'], [input_comp_dir video '.b' int2str(b) '.mpeg_dec.yuv'], 300, 352, 288);
    fprintf('%s, %d, %f\n', video, b, psnr);
    fprintf(fh, '%s, %d, %f\n', video, b, psnr);
end

fclose(fh);

