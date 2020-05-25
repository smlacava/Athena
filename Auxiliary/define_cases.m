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
%       (optional, if it is not selected, the function will search .mat, 
%       .edf, .eeg, .csv, .txt, .xls and .xlsx files)
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
            subject = search_cases(case_name, check, extensions, 0);     
            if isempty(subject)
                toDelete = [toDelete; i];
            else
                cases(i).name = strcat(path_check(cases(i).name), ...
                    subject(1).name);
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
    

function cases = search_cases(dataPath, check, extensions, check_single)
    if nargin == 3
        check_single = 1;
    end
    cases = [];
    for e = 1:length(extensions)
        if isempty(cases)
            cases = check_cases(dir(fullfile(char_check(dataPath), ...
                extensions{e})), check);
            if check_single == 1
                cases = single_file_detected(cases);
            end
        else
            break;
        end
    end
end


function extensions = define_extensions(extension)
    extensions = {'*.mat', '*.edf', '*.eeg', '*.csv', '*.txt', '*.xls', ...
        '*.xlsx'};
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


function [cases] = single_file_detected(cases)
    if max(size(cases)) == 1 && not(isempty(cases))
        bgc = [1 1 1];
        fgc = [0.067 0.118 0.424];
        btn = [0.427 0.804 0.722];
        answer = 'no';
        msg = strcat("A single possible file named ", cases(1).name, ...
            " has been detected. ", ...
            "Should I ignore it and continue the search?");
        f = figure;
        set(f, 'Position', [200 350 400 200], 'Color', bgc, ...
            'MenuBar', 'none', 'Name', 'Single file detected', ...
            'Visible', 'off', 'NumberTitle', 'off');
        ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
            'Position', [0.1 0.45 0.8 0.4], 'String', char(msg), ...
            'FontUnits', 'normalized', 'FontSize', 0.2, ...
            'BackgroundColor', bgc, 'ForegroundColor', 'k');
        hok = uicontrol('Style', 'pushbutton', 'String', 'yes',...
            'Units', 'normalized', 'Position', [0.2 0.05 0.25 0.2], ...
            'Callback', {@ok_Callback}, 'BackgroundColor', btn, ...
            'ForegroundColor', fgc); 
        hno = uicontrol('Style', 'pushbutton', 'String', 'no',...
            'Units', 'normalized', 'Position', [0.6 0.05 0.25 0.2], ...
            'Callback', {@no_Callback}, 'BackgroundColor', btn, ...
            'ForegroundColor', fgc); 
        hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
            'Position', [0 0.985 0.2 0.015], 'String', '', ...
            'FontUnits', 'normalized', ...
            'BackgroundColor', fgc, 'ForegroundColor', 'k');
        movegui(f, 'center')
        set(f, 'Visible', 'on')
        waitfor(hno)
        if strcmp(answer, 'yes')
            cases = [];
        end
    end
end

function ok_Callback(hObject, eventdata)
    evalin('caller', "answer = 'yes';");
    evalin('caller', 'close(f)')
end

function no_Callback(hObject, eventdata)
    evalin('caller', 'close(f)')
end