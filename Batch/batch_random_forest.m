%% batch_random_forest
% This function is used in the batch study to compute the random forest
% classification analysis
%
% batch_random_forest(parameters)
%
% input:
%   parameters is the cell array which contains the pairs name-value for
%       each parameter used in the batch study


function batch_random_forest(parameters)
    %random_forest(data, n_trees, resample_value, pruning, ...
    %       n_repetitions, min_samples, eval_method, split_value, ...
    %       reject_option)
    dataPath = search_parameter(parameters, 'dataPath');
    if strcmpi(search_parameter(parameters, ...
            'RF_DefaultClassification'), 'true')
        statistics = random_forest(dataPath, 31, 0.5, [], 100, 1, ...
            'split', 0.8, 0.5);
    else
        statistics = random_forest(dataPath, ...
            search_parameter(parameters, 'RF_TreesNumber'), ...
            search_parameter(parameters, 'RF_FResampleValue'), ...
            [], search_parameter(parameters, 'RF_Repetitions'), ...
            search_parameter(parameters, 'RF_MinimumClassExamples'), ...
            search_parameter(parameters, 'RF_Evaluation'), ...
            search_parameter(parameters, 'RF_TrainPercentage'), ...
            search_parameter(parameters, 'RF_Rejection'));
    end
    resultDir = strcat(path_check(dataPath), 'Classification');
    roc_fig = findobj( 'Type', 'Figure', 'Name', 'ROC curve' );
    roc_fig.Name = 'Random Forest ROC curve';
    cm_fig = findobj( 'Type', 'Figure', 'Name', 'Confusion Matrix' );
    cm_fig.Name = 'Random Forest Confusion Matrix';
    if not(exist(resultDir, 'dir'))
        mkdir(resultDir);
    end
    if sum(strcmp(parameters{45}, 'true'))
        save(strcat(path_check(resultDir), 'StatisticsRF.mat'), ...
            'statistics')
    else
       save(strcat(path_check(resultDir), 'Statistics.mat'), 'statistics')
    end
end