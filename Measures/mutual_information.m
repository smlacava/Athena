%% mutual_information
% This function computes the mutual information matrix on a time series,
% discretizating through the Freedman-Diaconis rule (the mutual information 
% related of the time series related to a location with itself will be 
% considered as zero).
%
% mi = mutual_information(data, normalization)
%
% Input:
%   data is the (samples x locations) time series matrix
%   normalization is the name of the normalization which has to be applied
%       on data, between 'zscore' (subtraction of the mean and division for
%       the standard deviation), 'max' (division for the maximum), 'minmax'
%       (subtraction of the minimum and division for the maximum minus the
%       minimum), no normalization otherwise (no normalization by default)
%
% Output:
%   mi is the (locations x locations) mutual information matrix

function mi = mutual_information(data, normalization)
    if nargin < 2
        normalization = [];
    end
    data = data';
    
    [N, L] = size(data);
    mi = zeros(N);
    
    mins = min(data, [], 2);
    maxs = max(data, [], 2);
    ranges = maxs - mins;
    bins = ceil(ranges./(2.0*iqr(data, 2).*L^(-1/3)));
    for i = 1:N
        for j = i+1:N
            points = ceil((bins(i)+bins(j))/2);
            [first_entropy, first_bins] = bins_entropy(data(i, :), ...
                points, mins(i), maxs(i));
            [second_entropy, second_bins] = bins_entropy(data(j, :), ...
                points, mins(j), maxs(j));
            jointentropy = bins_joint_entropy(points, first_bins, ...
                second_bins);
            mi(i, j) = sum([first_entropy; second_entropy]) - jointentropy;
            mi(j, i) = mi(i, j);
        end
    end
    mi = value_normalization(mi, normalization);
end


%% joint_entropy
% This function computes the joint entropy between two bins vectors.
%
% je = bins_joint_entropy(points, first_bins, second_bins)
%
% Input:
%   points is the number of points of which compute the joint probability
%   first_bins is the array which contains the values related to the first 
%       bins
%   second_bins is the array which contains the values related to the 
%       second bins
%
% Output:
%   je is the joint entropy value

function je = bins_joint_entropy(points, first_bins, second_bins)
    joint_probabilities = zeros(points);
    for k = 1:points
        for l = 1:points
            joint_probabilities(k, l) = sum(first_bins == k & ...
                second_bins == l);
        end
    end
    joint_probabilities = joint_probabilities./sum(joint_probabilities(:));
    je = -sum(joint_probabilities(:).*log2(joint_probabilities(:)+eps));
end


%% bins_entropy
% This function computes the entropy value related to histogram of a time 
% series.
%
% [ent, bins] = bins_entropy(data, points, minimum, maximum)
%
% Input:
%   data is the (1 x samples) time series
%   points is the number of bins used to evaluate the histogram
%   minimum is the minimum among the values of the data array
%   maximum is the maximum among the values of the data array

function [ent, bins] = bins_entropy(data, points, minimum, maximum)
    edges = linspace(minimum, maximum, points+1);
    [~, bins] = histc(data, edges);
    hdat = hist(data, points);
    hdat = hdat./sum(hdat);
    ent = -sum(hdat.*log2(hdat+eps));
end