%% batch_neural_network
% This function is used in the batch study to compute the neural network
% classification analysis
%
% batch_neural_network(parameters)
%
% input:
%   parameters is the cell array which contains the pairs name-value for
%       each parameter used in the batch study


function batch_neural_network(parameters)
    %neural_network(data, n_layers, validation_value,  ~, repetitions, ...
    %    min_samples, eval_method, training_value, reject_value)
    dataPath = search_parameter(parameters, 'dataPath');
    if strcmpi(search_parameter(parameters, ...
            'NN_DefaultClassificationParameters'), 'true')
        neural_network(dataPath, 10, 0.1, 1, 1, 100, 'split', 0.8, 0.5)
    else
        statistics = neural_network(dataPath, ...
            search_parameter(parameters, 'NN_HiddenLayersNumber'), ...
            search_parameter(parameters, 'NN_ValidationValue'), 1, ...
            search_parameter(parameters, 'NN_Repetitions'), ...
            search_parameter(parameters, 'NN_MinimumClassExamples'), ...
            search_parameter(parameters, 'NN_Evaluation'), ...
            search_parameter(parameters, 'NN_TrainPercentage'), ...
            search_parameter(parameters, 'NN_Rejection'));
    end
    resultDir = strcat(path_check(dataPath), 'Classification');
    if not(exist(resultDir, 'dir'))
        mkdir(resultDir);
    end
    if sum(strcmp(parameters{45}, 'true'))
        save(strcat(path_check(resultDir), 'StatisticsNN.mat'), ...
            'statistics')
    else
        save(strcat(path_check(resultDir), 'Statistics.mat'), 'statistics')
    end
end