%% split_set
% This function randomply split data (and labels) into a training set and a 
% testing set
%
% [data_train, data_test, labels_train, labels_test] = split_set(data, ...
%       labels, train_samples)
%
% input:
%   data is the matrix samples*features to split
%   labels is the cell array which contains the list of data labels
%   train_samples is the number of samples to use as train set (it can also
%       be a fraction number, such as 0.8)
%
% output:
%   data_train is the training set
%   data_test is the testing set
%   labels_train is the cell array which contains the labels of the
%       training set
%   labels_test is the cell array which contains the labels of the testing
%       set


function [data_train, data_test, labels_train, labels_test] = ...
    split_set(data, labels, train_samples)
    
    n = length(labels);
    n_classes = length(unique(labels));
    if nargin == 2
        train_samples = 0.5;
    end
    if train_samples < 1
        train_samples = train_samples*n;
    end
    train_samples = ceil(train_samples);
    
    if train_samples < n_classes
        data_train = [];
        labels_train = [];
        data_test = [];
        labels_test = [];
    else    
        idx = randperm(n);
        idx_train = idx(1:train_samples);
        idx_test = idx(train_samples+1:end);

        data_train = data(idx_train, :);
        data_test = data(idx_test, :);
        labels_train = labels(idx_train);
        labels_test = labels(idx_test);
    
        if length(unique(labels_train)) < n_classes
            [data_train, data_test, labels_train, labels_test] = split_data(data, labels, ...
                train_samples);
        end
    end
end