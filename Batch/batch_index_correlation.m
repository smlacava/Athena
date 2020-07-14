%% batch_index_correlation
% This function is used by the batch study to compute a correlation
% analysis between some measures and an index of an external file
%
% batch_index_correlation(parameters, managedPath, measure, Subjects, ...
%       nBands, locations, bg_color, save_check, format)
% 
% input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study
%   managedPath is the directory which contains the data matrices
%   measure is the measure which has to be correlated
%   Subjects is the subjects' matrix
%   nBands is the number of frequency bands
%   locations is the locations' list
%   bg_color is the background color's array
%   save_check is 1 if the user wants to save the resulting figure (0
%       otherwise)
%   format is the extension of the eventually saved image (.jpg or .fig)


function batch_index_correlation(parameters, managedPath, measure, ...
    Subjects, nBands, locations, bg_color, save_check, format)
    
    if not(exist(search_parameter(parameters, 'Index'), 'file'))
        problem(strcat("File ", search_parameter(parameters, 'Index'), ...
            " not found"))
        return
    end
    alpha = alpha_levelling(search_parameter(parameters, ...
        'Conservativeness_IC'), nBands, length(locations));
    Areas_IC = search_parameter(parameters, 'Areas_IC');
    for i = 1:length(Areas_IC)
        [data, ~, locs] = load_data(strcat(path_check(...
            strcat(managedPath, Areas_IC{i})), 'Second.mat'));
        nBands = define_nBands(data, Areas_IC{i});
        RHO = zeros(length(locs), nBands);
        P = RHO;

        [data, ~, locations] = load_data(char_check(...
            strcat(path_check(strcat(managedPath, Areas_IC{i})), ...
            search_parameter(parameters, 'Group_IC'), '.mat')));
        subs = {};
        if strcmp(char_check(search_parameter(parameters, 'Group_IC')), ...
                'Second')
            for s = 1:length(Subjects)
                if patient_check(char_check(Subjects(s, end)))
                    subs = [subs, char_check(Subjects(s, 1))];
                end
            end
        else
            for s = 1:length(Subjects)
                if not(patient_check(char_check(Subjects(s, end))))
                    subs = [subs, char_check(Subjects(s, 1))];
                end
            end
        end
        bands = search_parameter(parameters, 'frequency_bands');
        index_correlation(data, subs, bands, measure, ...
            search_parameter(parameters, 'Index'), alpha, bg_color, ...
            locations, P, RHO, length(locations), nBands, 1, ...
            search_parameter(parameters, 'dataPath'), save_check, format);
    end
    pause(2)
end



function nBands = define_nBands(data, area)
    nBands = 1;
    if length(size(data)) == 3
        nBands = size(data, 2);
    elseif sum(strcmpi(area, {'global', 'asymmetry'}))
        nBands = size(data);
        nBands = nBands(end);
    end
    if length(size(data)) == 1
        nBands = 1;
    end
end