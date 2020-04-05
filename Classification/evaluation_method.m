%% evaluation_method
% This function returns the evaluation function for the classification
%
% eval_function = evaluation_method(classifier, method)
%
% input:
%   classifier is the type of classifier;
%   method is the selected evaluation method's name
%
% output:
%   eval_function is the evaluation function (it is the training-test
%       split method by default)


function eval_function = evaluation_method(classifier, method)
    [functions, eval_function] = check_classifier(classifier);
    values = {'split', 'leaveoneout'};
    for i = 1:length(functions)
        if strcmpi(method, values{i})
            eval_function = functions{i};
            break;
        end
    end
end


function [functions, func] = check_classifier(classifier)
    nn = {'nn', 'neural', 'neuralnetwork', 'neural_network'};
    rf = {'rf', 'random_forest', 'randomforest', 'dt', 'decision_tree', ...
        'decisiontree'};
    if sum(strcmpi(classifier, nn))
        functions = {@nn_train_test_split, @nn_leave_one_out};
        func = @nn_train_test_split;
    elseif sum(strcmpi(classifier, rf))
        functions = {@rf_train_test_split, @rf_leave_one_out};
        func = @rf_train_test_split;
    end
end