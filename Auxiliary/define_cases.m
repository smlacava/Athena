%% define_cases
% This function returns a structure containing information about the time
% series present in the selected directory.
%
% cases = define_cases(dataPath)
%
% input:
%   dataPath is the directory which contains the time series to extract or
%       to analyse
%
% output:
%   cases is a structure which contains a time series name as the first
%       element of each row

function cases = define_cases(dataPath)
    dataPath = path_check(dataPath);
    cases = check_cases(dir(fullfile(char_check(dataPath), '*.mat')));
    if isempty(cases)
        cases = check_cases(dir(fullfile(dataPath, '*.edf')));
    end
end

function cases = check_cases(cases)
    toAvoid = {'._', 'Locations', 'Subjects', 'StatAn', 'Index'};
    for i = 1: length(toAvoid)
        cases = cases(not(contains({cases.name}, toAvoid{i})));
    end
end