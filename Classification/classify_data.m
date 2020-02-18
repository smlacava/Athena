%% classify_data
% This function return the most frequent class
%
% classification = classify_data(labels)
%
% input:
%   labels is the labels cell array
%
% output:
%   classification is the string which represents the most frequent class
%       inside the labels cell array


function classification = classify_data(labels)
    classes = unique(labels);
    n = length(classes);
    count_samples = zeros(n, 1);
    for i = 1:n
        count_samples(i, 1) = sum(strcmp(labels, classes{i}));
    end
    [~, index] = max(count_samples);
    classification = classes{index}; 
end

