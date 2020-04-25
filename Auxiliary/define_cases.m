%% define_cases
% This function returns a structure containing information about the time
% series present in the selected directory.
%
% cases = define_cases(dataPath, check, extension)
%
% input:
%   dataPath is the directory which contains the time series to extract or
%       to analyze
%   check is the variable which has to be 1 if the check on the cases names
%       has to be computed (1 by default)
%   exstension is the extension of the files which have to be searched
%       (optional, if it is not selected, the function will search .mat and
%       .edf files)
%
% output:
%   cases is a structure which contains a time series name as the first
%       element of each row


function cases = define_cases(dataPath, check, extension)
    if nargin == 1
        check = 1;
    end
    if nargin < 3
        extension =[];
    end
    
    dataPath = path_check(dataPath);
    extensions = define_extensions(extension);
    cases = search_cases(dataPath, check, extensions);
    
    if isempty(cases)
        toDelete = [];
        cases = check_cases(dir(dataPath), check);
        cases(strncmp({cases.name}, '.', 1),:) = [];
        for i = 1:length(cases)
            case_name = strcat(dataPath, cases(i).name);
            subject = search_cases(case_name, check, extensions);     
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
    

function cases = search_cases(dataPath, check, extensions)
    cases = [];
    for e = 1:length(extensions)
        if isempty(cases)
            cases = check_cases(dir(fullfile(char_check(dataPath), ...
                extensions{e})), check);
        else
            break;
        end
    end
end


function extensions = define_extensions(extension)
    extensions = {'*.mat', '*.edf'};
    if not(isempty(extension))
        if not(contains(extension, '.'))
            extension = char_check(strcat('.', extension));
        end
        if not(contains(extension, '*'))
            extension = char_check(strcat('*', extension));
        end
        extensions = [extension, extensions];
    end
end