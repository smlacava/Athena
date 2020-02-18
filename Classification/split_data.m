%% split_data
% This function make a feature-based split of input data on a split value
%
% [data_below, data_above, labels_below, labels_above] = ...
%       split_data(data, labels, feature_number, split_value)
%
% input:
%   data is the matrix samples*features to split
%   labels is the cell array which contains the labels of samples' classes
%   feature_number corresponds to the number of the column on which split
%       the data matrix
%   split_value is the value on which splits the data matrix
%
% output:
%   data_below is the data matrix which contains the samples having a
%       feature value inferior to the split value
%   data_above is the data matrix which contains the samples having a
%       feature value inferior to the split value
%   labels_below is the labels cell array which contains the samples having
%       a feature value inferior to the split value
%   labels_above is the labels cell array which contains the samples having
%       a feature value inferior to the split value


function [data_below, data_above, labels_below, labels_above] = ...
    split_data(data, labels, feature_number, split_value)
    split_feature_values = data(:, feature_number);
    data_below = data(split_feature_values <= split_value);
    data_above = data(split_feature_values > split_value);
    labels_below = labels(split_feature_values <= split_value);
    labels_above = labels(split_feature_values > split_value);
end

