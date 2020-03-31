%% rf_statistics
% This function creates the structure which contains parameters and
% statistics of the random forest classification
% 
% statistics = rf_statistics(data, evaluation_method, split_value, ...
%       n_trees, bagging_value, pruning, n_repetitions, min_samples, ...
%       accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
%       pca_value, pc, reject_value, rejected)
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
%   pca_value is the principal component analysis threshold value
%   pc is the principal component analysis figure
%   reject_value is the rejection threshold
%   rejected is the list of labels of the rejected samples
%
% output:
%   statistics is the resulting staistics structure


function statistics = rf_statistics(data, evaluation_method, ...
    split_value, n_trees, bagging_value, pruning, n_repetitions, ...
    min_samples, accuracy, min_accuracy, max_accuracy, cm, conf_mat, ...
    AUC, roc, pca_value, pc, reject_value, rejected)

    statistics.parameters = struct();
    statistics.parameters.pca = struct();
    statistics.parameters.pca.percentage = pca_value;
    statistics.parameters.pca.figure = pc;
    statistics.parameters.evaluation_method = evaluation_method;
    if strcmpi(evaluation_method, 'split')
        statistics.parameters.training_fraction = split_value;
    end
    statistics.parameters.trees_number = n_trees;
    statistics.parameters.bagging_value = bagging_value;
    statistics.parameters.pruning = pruning;
    statistics.parameters.repetitions = n_repetitions;
    statistics.parameters.min_samples = min_samples;
    statistics.accuracy = accuracy;
    statistics.min_accuracy = min_accuracy;
    statistics.max_accuracy = max_accuracy;
    statistics.confusion_matrix = struct();
    statistics.confusion_matrix.matrix = cm;
    statistics.confusion_matrix.rows = {'PAT', 'HC'};
    statistics.confusion_matrix.columns = ...
        {'PAT_predicted', 'HC_predicted'};
    statistics.confusion_matrix.figure = {conf_mat};
    statistics.ROC_curve = struct();
    statistics.ROC_curve.AUC = AUC;
    statistics.ROC_curve.figure = {roc};
    if not(isempty(rejected)) && reject_value > 0.5
        rejSUB = length(rejected);
        rejPAT = sum(rejected);
        rejHC = rejSUB-rejPAT;
        statistics.parameters.reject_value = reject_value;
        statistics.rejected = struct();
        statistics.rejected.list = rejected;
        statistics.rejected.PAT = rejPAT;
        statistics.rejected.HC = rejHC;
        statistics.rejected.average_rejected_PAT = rejPAT/n_repetitions;
        statistics.rejected.average_rejected_HC = rejHC/n_repetitions;
        if strcmpi(evaluation_method, 'split')
            statistics.rejected.average_nonrejected = ...
                (floor((1-split_value)*size(data, 1)))-...
                (rejSUB/n_repetitions);
        else
            statistics.rejected.average_nonrejected = ...
                size(data, 1)-(rejSUB/n_repetitions);
        end
end