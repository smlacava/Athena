%% calculate_entropy
% This function computes the entropy value of a set
%
% entropy = calculate_entropy(labels)
%
% input:
%   labels is the labels cell array
%
% output:
%   entropy is the entropy value


function entropy = calculate_entropy(labels)
    classes = unique(labels);
    n = length(classes);
    count_samples = zeros(n, 1);
    for i = 1:n
        count_samples(i, 1) = sum(strcmp(labels, classes{i}));
    end
    probabilities = count_samples/sum(count_samples);
    entropy = abs(sum(probabilities.*log2(probabilities)));
end

