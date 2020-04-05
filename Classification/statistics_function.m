%% statistics_function
% This function updates the structure which contains parameters and
% statistics of a classifier
% 
%statistics = statistics_function(statistics, data, pca_value, pc, ...
%    evaluation_method, training_value, n_repetitions, min_samples, ...
%    accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
%    rejected, reject_value)
%
% input:
%   statistics is the structure which has to be updated
%   data is the dataset table
%   pca_value is the principal component analysis threshold value
%   pc is the principal component analysis figure
%   evaluation_method is the used evaluation method 
%   training_value is the traning fraction
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


function statistics = statistics_function(statistics, data, pca_value, ...
    pc, evaluation_method, training_value, n_repetitions, min_samples, ...
    accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
    rejected, reject_value)

    statistics.parameters.pca = struct();
    statistics.parameters.pca.percentage = pca_value;
    statistics.parameters.pca.figure = pc;
    statistics.parameters.evaluation_method = evaluation_method;
    if strcmpi(evaluation_method, 'split')
        statistics.parameters.training_fraction = training_value;
    end
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
                (floor((1-training_value)*size(data, 1)))-...
                (rejSUB/n_repetitions);
        else
            statistics.rejected.average_nonrejected = ...
                size(data, 1)-(rejSUB/n_repetitions);
        end
    end
end