%% split_measurePath
% This function splits the data path related to a measure directory into
% the related main directory and the measure name.
%
% [dataPath, measure] = split_measurePath(dataPath)
% 
% Input:
%   dataPath is the measure directory
%
% Output:
%   dataPath is the main directory
%   measure is the name of the measure


function [dataPath, measure] = split_measurePath(dataPath)
    auxPath = split(dataPath, filesep);
    dataPath = '';
    measure = '';
    L = length(auxPath);
    for i = 1:L-1
        if not(isempty(auxPath(i+1))) && i < L-1
            dataPath = strcat(dataPath, path_check(auxPath(i)));
        else
            measure = auxPath(i);
            break;
        end
    end
    if strcmpi(measure, '')
        measure = auxPath(end);
    end
    
    measure = string(measure);
    dataPath = char(dataPath);
    dataPath = dataPath(1:end-1);
end
        
    