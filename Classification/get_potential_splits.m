%% potential_splits
% This function computes al potential splits between values of a feature
%
% potential_splits = get_potential_splits(data, random_subspace)
%
% input:
%   data is the matrix samples*features to classify
%   random_subspace is the number of features which have to be randomly
%       selected to compute the decision tree
%
% output:
%   potential splits is a row cell array which contains all possible splits
%       for each feature


function potential_splits = get_potential_splits(data, random_subspace)    
    n_features = size(data, 2);
    if nargin == 1
        random_subspace = n_features;
    end
    if not(isempty(random_subspace))
        if random_subspace < n_features
            features_indices = randperm(n_features);
            features_indices(random_subspace+1:end) = [];
        else
            random_subspace = n_features;
            features_indices = 1:n_features;
        end
    else
        random_subspace = n_features;
        features_indices = 1:n_features;
    end
    
    potential_splits = {};
    for i = 1:random_subspace
        unique_values = unique(data(:, features_indices(i)));
        aux_potential_splits = [];
        for j = 1:length(unique_values)
            if j ~= 1
                aux_potential_splits = [aux_potential_splits ...
                    (unique_values(j)+unique_values(j-1))/2];
            end
        end
        potential_splits = [potential_splits, aux_potential_splits];
    end
end