%% batch_pred_tomography: function description
function batch_pred_tomography()

    num_anom = 0.05;
    sigma_mags = [0:0.2:1];
    
    for sigma_mag = [sigma_mags]
        fprintf([num2str(num_anom) ' anomalies with size = ' num2str(sigma_mag) '\n']);
        pred_tomography(num_anom, sigma_mag);
    end

    fprintf('=====================\n');

    num_anoms = [0, 0.01, 0.03, 0.05, 0.07, 0.1];
    sigma_mag = 0.4;
    
    for num_anom = [num_anoms]
        fprintf([int2str(num_anom) ' anomalies with size = ' num2str(sigma_mag) '\n']);
        pred_tomography(num_anom, sigma_mag);
    end

end
