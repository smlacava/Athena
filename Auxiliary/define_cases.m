%% define_cases
% This function returns a structure containing information about the time
% series present in the selected directory.
%
% [cases] = define_cases(dataPath)
%
% input:
%   dataPath is the directory which contains the time series to extract or
%       to analyse
%
% output:
%   cases is a structure which contains a time series name as the first
%       element of each row

function cases=define_cases(dataPath)
    dataPath=path_check(dataPath);
    cases=dir(fullfile(dataPath,'*.mat'));
    if isempty(cases)
        cases=dir(fullfile(dataPath,'*.edf'));
    end
end