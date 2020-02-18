%% calculate_overall_entropy
% This function computes the overal entropy of a data splitting
%
% overall_entropy = calculate_overall_entropy(labels_below, labels_above)
%
% input:
%   labels_below is the labels cell array of data with a feature value
%       below a split value
%   labels_above is the labels cell array of data with a feature value
%       above a split value
%
% output:
%   overall_entropy is the overall entropy value


function overall_entropy = calculate_overall_entropy(labels_below, ...
    labels_above)
    samples_below = length(labels_below);
    samples_above = length(labels_above);
    total_samples = samples_above+samples_below;
    
    probability_below = samples_below/total_samples;
    probability_above = samples_above/total_samples;
    
    entropy_below = probability_below*calculate_entropy(labels_below);
    entropy_above = probability_above*calculate_entropy(labels_above);
    overall_entropy = entropy_below+entropy_above;
end