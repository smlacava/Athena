%% split_data
% This function is used to divide data set in training set and testing set
%
% [dataTrain, dataTest] = split_data(data, testing_fraction, min_samples)
%
% input:
%   data is the data set
%   testing_fraction is the fraction of data which has to be used as
%       testing set
%   min_samples is the minimum number of samples for each class in training
%       set and in testing set (optional)
%   
% output:
%   dataTrain is the training set
%   dataTest is the testing set


function [dataTrain, dataTest] = split_data(data, testing_fraction, ...
    min_samples)
    cvpt = cvpartition(data.group, "Holdout", testing_fraction);
    dataTrain = data(training(cvpt),:);
    n_train = size(data, 1);
    
    if nargin == 3
        group_check = sum(dataTrain.group == 0);
        while group_check == n_train || group_check < min_samples
            cvpt = cvpartition(data.group, "Holdout", testing_fraction);
            dataTrain = data(training(cvpt),:);
            group_check = sum(dataTrain.group == 0);
        end
    end
    
    dataTest = data(test(cvpt), :);
end