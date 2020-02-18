%% random_forest_algorithm
% This function computes the random forest model
%
% forest = random_forest_algorithm(data_train, labels_train, n_trees, ...
%       n_bootstrap, max_depth, random_subspace, features)
%
% input:
%   data_train is the training data set
%   labels_train is the training labels cell array
%   n_trees is the number of trees to compute
%   n_bootstrap is the number of randomly chosen examples to use to compute 
%       each decision tree
%   max_depth is the maximum depth of each decision tree
%   random_subspace is the number of features to consider in the
%       construction of each tree
%   features is the cell array which contains the names of each feature
%
% output:
%   forest is the cell array which contains each decision tree


function forest = random_forest_algorithm(data_train, labels_train, ...
    n_trees, n_bootstrap, max_depth, random_subspace, features)
    switch nargin
        case 4
            max_depth = Inf;
            random_subspace = [];
            features = [];
        case 5
            random_subspace = [];
            features = [];
        case 6
            features = [];
    end
    
    if isempty(random_subspace)
        random_subspace = size(data_train, 1);
    elseif random_subspace < 1
        random_subspace = random_subspace*size(data, 1);
    end
    
    forest = cell(n_trees, 1);
    for i = 1:n_trees
        [data_bs, labels_bs] = bootstrapping(data_train, labels_train, ...
            n_bootstrap);
        forest{i, 1} = decision_tree_algorithm(data_bs, labels_bs, 0, ...
            max_depth, random_subspace, features);
    end
end
        