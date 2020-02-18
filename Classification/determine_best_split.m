%% determine_best_split
% This function is used to determine the feature and the value of this one
% to use for the following split to obtain the best split, in terms of
% entropy
%
% [feature, value] = determine_best_split(data, labels, potential_splits)
%
% input:
%   data is the data matrix samples*features
%   labels is the labels cell array
%   potential_splits is the cell array which contains the possible splits
%       values for each feature
%
% output:
%   feature is the number of feature (the column index) on which compute
%       the best possible split
%   value is the value of the feature to use to compute the best possible
%       split


function [feature, value] = determine_best_split(data, labels, ...
    potential_splits)
    overall_entropy = Inf;
    for i = 1:length(potential_splits)
        aux_potential_splits = potential_splits{i};
        for j = 1:length(aux_potential_splits)
            [~, ~, labels_below, labels_above] = split_data(data, ...
                labels, i, aux_potential_splits(j));
            current_overall_entropy = ...
                calculate_overall_entropy(labels_below, labels_above);
            
            if current_overall_entropy <= overall_entropy
                overall_entropy = current_overall_entropy;
                feature = i;
                value = aux_potential_splits(j);
            end
        end
    end
end