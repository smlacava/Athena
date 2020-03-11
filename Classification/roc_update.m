%% roc_update
% This function updates the AUC value and the vectors which represents the
% ROC curve (all the resulting values have to be divided by the number of
% classification repetitions)
%
% [scores, labels] = roc_update(scores, labels, new_scores, new_labels, ...
%       repetition_number, dimension)
%
% input:
%   scores is the array which has to be filled with all the testing sets' 
%     class labels
%   labels is the array which has to be filled with all the predictions' 
%     scores
%   new_scores is the matrix of scores which have to be added
%   new_labels is the array of class labels which have to be added
%   repetition_number is the classification repetition number
%   dimension is the number of testing examples
%
% output:
%   scores is the updated scores array
%   labels is the updated labels array


function [scores, labels] = roc_update(scores, labels, new_scores, ...
    new_labels, repetition_number, dimension)
    initial_index = (repetition_number-1)*dimension+1;
    final_index = repetition_number*dimension;
    scores(initial_index:final_index) = new_scores(:, 2);
    labels(initial_index:final_index) = new_labels;
end