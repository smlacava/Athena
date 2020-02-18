%% decision_tree_algorithm
% This function computes a training iteration
%
% [tree, labels] = decision_tree_algorithm(data, labels, counter...
%       max_depth, random_subspace, features)
% input:
%   data is the data matrix samples*features
%   labels is the labels cell array
%   counter is the number of iteration
%   max_depth is the maximum depth of the classification tree (if this
%       value is reached, there will be a pruning)
%   random_subspace is the number of features which have to be randomly
%       selected to compute the decision tree
%   features is the cell array which contains the name of each feature
%
% output:
%   tree the computed decision tree model
%   labels is the set of labels for each branch of the current node


function [tree, labels] = decision_tree_algorithm(data, labels, ...
    counter, max_depth, random_subspace, features)
    switch nargin 
        case 2
            counter = 0;
            max_depth = Inf;
            random_subspace = [];
            features = string(1:size(data, 2));
        case 3
            max_depth = Inf;
            random_subspace = [];
            features = string(1:size(data, 2));
        case 4
            random_subspace = [];
            features = string(1:size(data, 2));
        case 5
            features = string(1:size(data, 2));
    end
    
    
    if isempty(max_depth)
        max_depth = Inf;
    end
    if isempty(counter)
        counter = 0;
    end
    if isempty(features)
        features = {string(1:size(data, 2))};
    end
    
    if not(iscell(features))
        features = {features};
    end
    
    if counter == 0
        tree = struct();
    end

    if check_purity(labels) || counter == max_depth
        tree = classify_data(labels);
        return;
    else
        counter = counter+1;
        potential_splits = get_potential_splits(data, random_subspace);
        [feature, value] = determine_best_split(data, labels, ...
            potential_splits);
        %[data_below, data_above, labels_below, labels_above] = ...
            %split_data(data, labels, feature, value);
        
        %[below_answer, below_labels] = ...
            %decision_tree_algorithm(data_below, labels_below, counter, ...
            %max_depth, random_subspace);
        %[above_answer, above_labels] = ...
            %decision_tree_algorithm(data_above, labels_above, counter, ...
            %max_depth, random_subspace);

        %tree = {strcat(features{feature}, " <= ", string(value)), ...
            %below_answer, above_answer};
        %labels = {below_labels, above_labels};
        
        tree.condition = [features{feature}, value];
        tree.left = decisionTreeTrain(below_answer, below_labels, ...
            counter, max_depth, random_subspace);
        tree.right = decisionTreeTrain(above_answer, above_labels, ...
            counter, max_depth, random_subspace);
     end
end