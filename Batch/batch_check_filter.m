%% batch_check_filter
% This function is used during the batch study in order to set the filter
% function which has to be used
%
% filter_file = batch_check_filter(filter_file)
%
% Input:
%   filter_file is the name of the file (eventually with its path) which
%       contains the filtering function wich has to have the same name
%
% Output:
%   filter_file is the name of the filter_file (without the extension)


function filter_file = batch_check_filter(filter_file)
    if contains(filter_file, filesep)
    	aux_answer = split(filter_file, filesep);
        filter_file = aux_answer{end};
        path = '';
        for i = 1:length(aux_answer)-1
            path = strcat(path, aux_answer{i}, filesep);
        end
        addpath(path);
    end
    filter_file = strtok(filter_file, '.');
end