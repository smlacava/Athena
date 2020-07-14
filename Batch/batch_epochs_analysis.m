%% batch_epochs_analysis
% This function is used by the batch study to verify the variation of a
% measure during the epochs.
%
% batch_epochs_analysis(parameters, dataPath, measure, nBands, ...
%       n_measures, save_check, format)
% 
% input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study
%   measure is the measure which has to be correlated
%   nBands is the number of frequency bands
%   n_measures is the number of measures
%   save_check is 1 if the user wants to save the resulting figure (0
%       otherwise)
%   format is the extension of the eventually saved image (.jpg or .fig)


function batch_epochs_analysis(parameters, dataPath, measure, nBands, ...
    n_measures, save_check, format)
    locFile = search_parameter(parameters, 'Locations');
    if not(exist(locFile, 'file'))
        if n_bands == 1
            aux_measure = measure;
        else
            aux_measure = measure{1};
        end
        if exist(strcat(path_check(locFile), path_check(aux_measure), ...
                'Locations.mat'), 'file')
            locFile = strcat(path_check(locFile), 'Locations.mat');
        else
            problem(strcat("File ", locFile, " not found"))
            return
        end
    end
    
    Areas_EA = search_parameter(parameters, 'Areas_EA');
    for m = 1:n_measures
        for i = 1:length(Areas_EA)
            epochs_analysis(dataPath, ...
                search_parameter(parameters, 'Subject'), ...
                areas_check(Areas_EA{i,1}), measure, ...
                search_parameter(parameters, 'epNum'), nBands, locFile, ...
                save_check, format)
        end
    end
end