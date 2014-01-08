

best_mae = 99999;
best_alpha = 0;

lambda = 0;
for alpha = [0 0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000 10000 100000 1000000]
    
    fprintf('>>> alpha=%f, lambda=%f\n', alpha, lambda);

    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, best_thresh] = srmf_based_pred('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs1.all.bin10.txt', 100, 458, 1, 100, 10, 'org', 'srmf', '2d','elem', 'ind', 1, 0.6, 1, 0, 0, 0.3, 1, alpha, lambda);

    if(best_mae < 0 | mae < best_mae)
        best_alpha = alpha;
        best_mae = mae;
    end
    
end



alpha = best_alpha;
best_lambda = 0;

for lambda = [0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000 10000 100000 1000000 10000000 100000000 1000000000]
% for lambda = [1000000 10000000 100000000 1000000000]
    
    fprintf('>>> alpha=%f, lambda=%f\n', alpha, lambda);

    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, best_thresh] = srmf_based_pred('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs1.all.bin10.txt', 100, 458, 1, 100, 10, 'org', 'srmf', '2d','elem', 'ind', 1, 0.6, 1, 0, 0, 0.3, 1, alpha, lambda);

    if(mae < best_mae)
        best_lambda = lambda;
        best_mae = mae;
    end
    
end


best_alpha
best_lambda
best_mae