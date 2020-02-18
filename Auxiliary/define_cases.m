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
    if isempty(cases)
        toDelete = [];
        cases = check_cases(dir(dataPath));
        cases(strncmp({cases.name}, '.', 1),:) = [];
        for i = 1:length(cases)
            subject = check_cases(dir(fullfile(path_check(...
                strcat(dataPath, cases(i).name)), '*.mat')));
            if isempty(subject)
                subject = check_cases(dir(fullfile(path_check(...
                    strcat(dataPath, cases(i).name)), '*.edf')));
            end
            
            if isempty(subject)
                toDelete = [toDelete; i];
            else
                cases(i).name = strcat(path_check(cases(i).name), subject.name);
            end
        end
        cases(toDelete) = [];
    end     
end

function cases = check_cases(cases)
    toAvoid = {'Locations', 'Subjects', 'StatAn', 'Index', 'PSDr', ...
        'AEC', 'AECc', 'AECo', 'offset', 'exponential', 'PLI', 'PLV', ...
        'HC', 'PAT'};
    for i = 1:length(toAvoid)
        cases = cases(not(contains({cases.name}, toAvoid{i})));
    end
    cases = cases(not(strncmp({cases.name}, '.', 1)));   
end
    
    