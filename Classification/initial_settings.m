%% initial_settings
% This function computes the initial classification settings
%
% [params_dim, scores, labels, accuracy, min_accuracy, max_accuracy, ...
%    cm, n_HC, n_PAT, eval_func, testing_fraction, variable_param] = ...
%    initial_settings(classifier, data, n_repetitions, eval_method, ...
%    training_value, variable_param)
%
% input:
%   classifier is the classifier's type (random forest classifier, decision 
%       treeclassifier or neural network classifier)
%   data is the data table
%   n_repetitions is the number of classification repetitions
%   eval_method is the selected evaluation method
%   training_value is the training fraction (or training examples number)
%   variable_parameter depends on the classifier's type (pruning if it is a
%       random forest classifier or a decision tree classifier, validation
%       fraction if it is a neural network classifier)
%
% output:
%   testing_fraction is the testing fraction
%   params_dim is the parameters dimension used by scores and labels arrays
%   scores is the initial scores array
%   labels is the initial labels array
%   accuracy is the initial accuracy value
%   min_accuracy is the initial minimum accuracy value
%   max_accuracy is the initial maximum accuracy
%   cm is the initial confusion matrix
%   n_HC is the initial number of healthy controls
%   n_PAT is the initial number of patients
%   eval_func is the evaluation function
%   variable_parameter depends on the classifier's type (pruning if it is a
%       random forest classifier or a decision tree classifier, validation
%       fraction if it is a neural network classifier)


function [params_dim, scores, labels, accuracy, min_accuracy, max_accuracy, ...
    cm, n_HC, n_PAT, eval_func, testing_fraction, variable_param] = ...
    initial_settings(classifier, data, n_repetitions, eval_method, ...
    training_value, variable_param)

    n_examples = size(data, 1);
    if training_value >= 1
        training_value = training_value/n_examples;
    end
    
    is_func = check_initial_settings_function(classifier);
    [eval_func, variable_param, testing_fraction] = ...
        is_func(eval_method, variable_param, training_value);
    
    params_dim = floor(n_examples*testing_fraction);
    labels = zeros(params_dim*n_repetitions, 1);
    scores = labels;
    accuracy = 0;
    max_accuracy = 0;
    min_accuracy = 1;
    cm = zeros(2, 2);  %[true_PAT, false_HC; false_PAT, true_HC]
    n_HC = 0;
    n_PAT = 0;
end


function is_function = check_initial_settings_function(classifier)
    if sum(strcmpi(classifier, {'nn', 'neural', 'neuralnetwork', ...
            'neural_network', 'nnc', 'neuralnetworkclassifier', ...
            'neural_network_classifier'})) > 0
        is_function = @nn_initial_settings;
    elseif sum(strcmpi(classifier, {'rf', 'randomforest', 'dt', 'dtc', ...
            'random_forest', 'decision_tree', 'randomforestclassifier', ...
            'decisiontree', 'decision_tree_classifier', 'rfc', ...
            'random_forest_classifier'})) > 0
        is_function = @rf_initial_settings;
    end
end


function [eval_func, pruning, testing_fraction] = ...
    rf_initial_settings(eval_method, pruning, training_value, ~)

    if isempty(pruning)
        pruning = 'off';
    end
    if sum(strcmpi(string(pruning), {'true', '1'}))
        pruning = 'on';
    elseif sum(strcmpi(string(pruning), {'false', '0'}))
        pruning = 'off';
    end
    eval_func = evaluation_method('rf', eval_method);
    testing_fraction = 1-training_value;
end


function [eval_func, validation_value, testing_fraction] = ...
    nn_initial_settings(eval_method, validation_value, training_value, ...
    n_samples)

    if validation_value >= 1
        validation_value = validation_value/n_samples;
    end
    eval_func = evaluation_method('nn', eval_method);
    testing_fraction = 1-training_value-validation_value;
end
    