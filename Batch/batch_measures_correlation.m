%% batch_measures_correlation
% This function is used by the batch study to compute a correlation
% analysis between two measures using the same spatial parameters
%
% batch_measures_correlation(parameters, dataPath, locations, bg_color, ...
%       save_check, format)
% 
% input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study
%   dataPath is the main directory of the study
%   locations is the locations' list
%   bg_color is the background color's array
%   save_check is 1 if the user wants to save the resulting figure (0
%       otherwise)
%   format is the extension of the eventually saved image (.jpg or .fig)


function batch_measures_correlation(parameters, dataPath, locations, ...
    bg_color, save_check, format)
    Areas_MC = search_parameter(parameters, 'Areas_MC');
    for i = 1:length(Areas_MC)
        [xData, yData, nLoc, nBands, locs] = ...
            batch_measures_correlation_settings(...
            search_parameter(parameters, 'Measure1'), ...
            search_parameter(parameters, 'Measure2'), dataPath, ...
            Areas_MC{i}, search_parameter(parameters, 'Group_MC'));
        alpha = alpha_levelling(search_parameter(parameters, ...
            'Conservativeness_MC'), nBands, length(locations));
        if isempty(nBands)
            return;
        end
        bands = cell(1, nBands);
        for b = 1:nBands
            bands{1, b} = char_check(strcat("Band ", string(b)));
        end
        band_name = batch_define_bands(parameters, ...
            search_parameter(parameters, 'Measure1'));
        measures_correlation(xData, yData, ...
            search_parameter(parameters, 'Group_MC'), band_name, ...
            {search_parameter(parameters, 'Measure1'), ...
            search_parameter(parameters, 'Measure2')}, alpha, ...
            bg_color, locs, [], [], nLoc, nBands, 1, ...
            search_parameter(parameters, 'dataPath'), save_check, format)   
    end
end