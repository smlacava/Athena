%% classification
% This function returns the accurracy of the classification on a data set
% 
% accuracy = classification(data, labels, train_samples, max_depth, ...
%     random_subspace, features)
%
% input:
%   data is the data matrix samples*features
%   labels is the labels cell array
%   train_samples is the number of samples to use as training set (an
%       integer number or a percentage, 0.8 as default)
%   max_depth is the maximum depth of the decision tree(Inf as default)
%   random_subspace is the number of features which have to be randomly
%       selected to compute the decision tree
%    features is the features names cell array
%
% output:
%   accuracy is the resulting accuracy value


function accuracy = classification(data, labels, train_samples, ...
    n_trees, n_bootstrap, max_depth, random_subspace, features)
    switch nargin
        case 2
            train_samples = 0.8;
            max_depth = Inf;
            random_subspace = [];
            features = [];
        case 3
            max_depth = Inf;
            random_subspace = [];
            features = [];
        case 4
            random_subspace = [];
            features = [];
        case 5
            features = [];
    end
    
    [train, test, labels_train, labels_test] = split_set(data, labels, ...
        train_samples);
    forest = random_forest_algorithm(train, labels_train, ...
        n_trees, n_bootstrap, max_depth, random_subspace, features);
    predictions = random_forest_predictions(test, forest);
    accuracy = calculate_accuracy(predictions, labels_test);
end