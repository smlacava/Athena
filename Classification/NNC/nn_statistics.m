%% nn_statistics
% This function creates the structure which contains parameters and
% statistics of the neural network classification
% 
%statistics = nn_statistics(data, eval_method, training_value, ...
%        validation_value, n_layers, repetitions, min_samples, ...
%        accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
%        reject_value, rejected)
%
% input:
%   data is the dataset table
%   evaluation_method is the used evaluation method 
%   training_value is the traning fraction
%   validation_value is the validation fraction
%   n_layers is the number of hidden layers
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


function statistics = nn_statistics(data, evaluation_method, ...
        training_value, validation_value, n_layers, n_repetitions, ...
        min_samples, accuracy, min_accuracy, max_accuracy, cm, ...
        conf_mat, AUC, roc, reject_value, rejected)

    statistics.parameters = struct();
    statistics.parameters.validation_fraction = validation_value;
    statistics.parameters.hidden_layers = n_layers;
    
    statistics = statistics_function(statistics, data, ...
        evaluation_method, training_value+validation_value, ...
        n_repetitions, min_samples, accuracy, min_accuracy, ...
        max_accuracy, cm, conf_mat, AUC, roc, rejected, reject_value);
    