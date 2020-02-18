%% bootstrapping
% This function computes the bootstrapping of the training data set
%
% [data_train, labels_train] = bootstrapping(data_train, labels_train, ...
%       n_bootstrap)
%
% input:
%   data_train is the training data set
%   labels_train is the labels cell array of the training data set
%   n_bootstrap is the number (or the percentage) of examples to extract
%
% output:
%   data_train is the resulting training data set
%   labels_train is the labels cell array of the training data set


function [data_train, labels_train] = bootstrapping(data_train, ...
    labels_train, n_bootstrap)
    n_samples = size(data_train, 1);
    if n_bootstrap < 1
        n_bootstrap = ceil(n_bootstrap*n_samples);
    end
    if n_bootstrap < n_samples
        random_indices = randperm(n_samples);
        del_indices = random_indices(n_bootstrap+1:end);
        data_train(del_indices, :) = [];
        labels_train(del_indices) = [];
    end
end