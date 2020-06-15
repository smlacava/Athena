%% rf_statistics
% This function creates the structure which contains parameters and
% statistics of the random forest classification
% 
% statistics = rf_statistics(data, evaluation_method, split_value, ...
%       n_trees, bagging_value, pruning, n_repetitions, min_samples, ...
%       accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
%       reject_value, rejected)
%
% input:
%   data is the dataset table
%   evaluation_method is the used evaluation method 
%   split_value is the traning fraction
%   n_trees is the number of trees which had been considered
%   bagging_value is the bagging fraction
%   pruning is the pruning parameter
%   n_repetitions is the number of classification repetitions
%   min_samples is the minimum number of training examples for each class
%   accuracy is the averaged accuracy value
%   min_accuracy is the minimum accuracy occurred
%   max_accuracy is the maximum accuracy occurred
%   cm is the averaged confusion matrix
%   conf_mat is the confusion matrix figure
%   AUC is the overall AUC value
%   roc is the roc curve figure
%   reject_value is the rejection threshold
%   rejected is the list of labels of the rejected samples
%
% output:
%   statistics is the resulting staistics structure


function statistics = rf_statistics(data, evaluation_method, ...
    split_value, n_trees, bagging_value, pruning, n_repetitions, ...
    min_samples, accuracy, min_accuracy, max_accuracy, cm, conf_mat, ...
    AUC, roc, reject_value, rejected)

    statistics.parameters = struct();
    statistics.parameters.trees_number = n_trees;
    statistics.parameters.bagging_value = bagging_value;
    statistics.parameters.pruning = pruning;
    
    statistics = statistics_function(statistics, data, ...
    	evaluation_method, split_value, n_repetitions, min_samples, ...
        accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
        rejected, reject_value);
end