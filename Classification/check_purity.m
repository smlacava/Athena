%% check_purity
% This function checks if all the labels belong to only one class
%
% result = check_purity(labels)
%
% input:
%   labels is the labels cell array
%
% output:
%   result is true if all the labels belong to only one class, and false
%       otherwise


function result = check_purity(labels)
    classes = unique(labels);
    if length(classes) == 1
        result = true;
    else
        result = false;
    end
end

