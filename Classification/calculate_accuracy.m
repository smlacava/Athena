%% calculate_accuracy
% This function computes the accuracy value of a decision trees set
%
% accuracy = calculate_accuracy(data_test, labels_test)
%
% input:
%   data_test is the testing data matrix samples*features
%   labels_test is the testing labels cell array
%
% output:
%   accuracy is the resulting accuracy value


function accuracy = calculate_accuracy(predictions, labels_test)
    accuracy = mean(strcmp(predictions, labels_test));
end

