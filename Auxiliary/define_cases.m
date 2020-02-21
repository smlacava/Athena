%% define_cases
% This function returns a structure containing information about the time
% series present in the selected directory.
%
% cases = define_cases(dataPath, check)
%
% input:
%   dataPath is the directory which contains the time series to extract or
%       to analyse
%   check is the variable which has to be 1 if the check on the cases names
%       has to be computed (1 by default)
%
% output:
%   cases is a structure which contains a time series name as the first
%       element of each row

function cases = define_cases(dataPath, check)
    if nargin == 1
        check = 1;
    end
    dataPath = path_check(dataPath);
    cases = check_cases(dir(fullfile(char_check(dataPath), '*.mat')), ...
        check);
    if isempty(cases)
        cases = check_cases(dir(fullfile(dataPath, '*.edf')), check);
    end
    if isempty(cases)
        toDelete = [];
        cases = check_cases(dir(dataPath), check);
        cases(strncmp({cases.name}, '.', 1),:) = [];
        for i = 1:length(cases)
            subject = check_cases(dir(fullfile(path_check(...
                strcat(dataPath, cases(i).name)), '*.mat')), check);
            if isempty(subject)
                subject = check_cases(dir(fullfile(path_check(...
                    strcat(dataPath, cases(i).name)), '*.edf')), check);
            end
            
            if isempty(subject)
                toDelete = [toDelete; i];
            else
                cases(i).name = strcat(path_check(cases(i).name), ...
                    subject.name);
            end
        end
        cases(toDelete) = [];
    end     
end

function cases = check_cases(cases, check)
    if check == 1
        toAvoid = {'Locations', 'Subjects', 'StatAn', 'Index', 'PSDr', ...
            'AEC', 'AECc', 'AECo', 'offset', 'exponential', 'PLI', ...
            'PLV', 'HC', 'PAT', 'Classification'};
        for i = 1:length(toAvoid)
            cases = cases(not(contains({cases.name}, toAvoid{i})));
        end
    end
    cases = cases(not(strncmp({cases.name}, '.', 1)));   
end
    
    