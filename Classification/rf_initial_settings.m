%% rf_initial_settings
% This function computes the initial random forest classification settings
%
% [testing_fraction, params_dim, scores, pruning, accuracy, labels, ...
%       max_accuracy, min_accuracy, cm, n_HC, n_PAT] = ...
%       rf_initial_settings(data, n_repetitions, pruning, eval_method, ...
%       split_value)
%
% input:
%   data is the data table
%   n_repetitions is the number of classification repetitions
%   pruning is the pruning parameter
%   eval_method is the selected evaluation method
%   split_value is the training fraction (or training examples number)
%
% output:
%   testing_fraction is the testing fraction
%   params_dim is the parameters dimension used by scores and labels arrays
%   scores is the initial scores array
%   labels is the initial labels array
%   pruning is the pruning parameter
%   accuracy is the initial accuracy value
%   min_accuracy is the initial minimum accuracy value
%   max_accuracy is the initial maximum accuracy
%   cm is the initial confusion matrix
%   n_HC is the initial number of healthy controls
%   n_PAT is the initial number of patients
%   eval_func is the evaluation function


function [testing_fraction, params_dim, scores, labels, pruning, ...
    accuracy, min_accuracy, max_accuracy, cm, n_HC, n_PAT, eval_func] = ...
    rf_initial_settings(data, n_repetitions, pruning, eval_method, ...
    split_value)
    
    n_examples = size(data, 1);
    if split_value >= 1
        split_value = split_value/n_examples;
    end
    if isempty(pruning)
        pruning = 'off';
    end
    testing_fraction = 1-split_value;
    params_dim = floor(n_examples*testing_fraction);
    labels = zeros(params_dim*n_repetitions, 1);
    scores = labels;
    if sum(strcmpi(string(pruning), {'true', '1'}))
        pruning = 'on';
    elseif sum(strcmpi(string(pruning), {'false', '0'}))
        pruning = 'off';
    end
    eval_func = rf_evaluation_method(eval_method);
    accuracy = 0;
    max_accuracy = 0;
    min_accuracy = 1;
    cm = zeros(2, 2);  %[true_PAT, false_HC; false_PAT, true_HC]
    n_HC = 0;
    n_PAT = 0;
end