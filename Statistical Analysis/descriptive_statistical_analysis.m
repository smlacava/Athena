%% descriptive_statistical_analysis
% This function compute the descriptive statistical analysis on a measure
% matrix, allowing to select the frequency band and the location to
% analyze, summarizing the results in a table.
%
% [results, group_names] = descriptive_statistical_analysis(dataPath, ...
%     measure, area, band_number, location_number, sub_types, ...
%     location_name, band_name, figureFLAG)
%
% Input:
%   dataPath is the name of the main folder of the study
%   measure is the name of the measure which has to be analyzed
%   area is the type of the area of the study (Total, Areas, Asymmetry, or
%       Global)
%   band_number is the number of the frequency band to analyze
%   location_number is the index of the location to analyze
%   sub_types is the cell array which contains the names of the groups of
%       the subjects
%   location_name is the name of the location to analyze (optional)
%   band_name is the name of the frequency band to analyze (optional)
%   figureFLAG has to be 1 in order to export the resulting figure, 0
%       otherwise (1 by default)
%   
% Output:
%   results is the resulting table which summarizes the descriptive
%       statistical values
%   group_names is the cell array which contains the list of the analyzed 
%       groups


function [results, group_names] = ...
    descriptive_statistical_analysis(dataPath, measure, ...
    area, band_number, location_number, sub_types, location_name, ...
    band_name, figureFLAG)
    
    if nargin < 7
        location_name = '';
    end
    if nargin < 8
        band_name = '';
    end
    if nargin < 9
        figureFLAG = 1;
    end
        
    measure_path = measurePath(dataPath, measure, area);  
    if sum(contains(area, {'Asymmetry', 'Global'})) == 0
        location_number = 1;
    end
    
    group_names = {};
    results = [];
    
    HC_file = strcat(measure_path, 'First.mat');
    if exist(HC_file, 'file')
        HC = load_data(HC_file);
        HC = check_data(HC, location_number, band_number);
        [mean_HC, median_HC, variance_HC, max_HC, min_HC, kurtosis_HC, ...
            skewness_HC] = descriptive_statistics(HC);
        if not(isnan(mean_HC))
            group_names = [group_names, sub_types{1}];
            results = [results, [mean_HC; median_HC; variance_HC; ...
                max_HC; min_HC; kurtosis_HC; skewness_HC]];
        end
    end
    
    PAT_file = strcat(measure_path, 'Second.mat');
    if exist(PAT_file, 'file')
        PAT = load_data(PAT_file);
        PAT = check_data(PAT, location_number, band_number);
        [mean_PAT, median_PAT, variance_PAT, max_PAT, min_PAT, ...
            kurtosis_PAT, skewness_PAT] = descriptive_statistics(PAT);
        if not(isnan(mean_PAT))
            group_names = [group_names, sub_types{2}];
            results = [results, [mean_PAT; median_PAT; variance_PAT; ...
                max_PAT; min_PAT; kurtosis_PAT; skewness_PAT]];
        end
    end
    
    if figureFLAG == 1 && not(isempty(results))
        statistics_names = {'Mean', 'Median', 'Variance', 'Maximum', ...
            'Minimum', 'Kurtosis', 'Skewness'};
        name = strcat("Descriptive Statistical Analysis - ", ...
            measure, " ", location_name, " ", band_name);
        bg_color = [1 1 1];
        fdsa = figure('Name', name, 'NumberTitle', 'off', ...
            'Color', bg_color);
        dsa = uitable(fdsa, 'Data', results, 'Position', ...
            [20 20 525 375], 'RowName', statistics_names, 'ColumnName', ...
            group_names);
    end    
end



%% check_data
% This function returns the data vector used in distribution analysis
% 
% data = check_data(data, loc, band)
%
% Input:
%   data is the data matrix
%   loc is the location index
%   band is the frequency band index
%
% Output:
%   data is the data array

function data = check_data(data, loc, band)
    dim = length(size(data));
    aux_idx = max(loc, band);
    if dim == 1
        data = data(aux_idx);
    elseif dim == 2 && min(loc, band) == 1
        data = data(:, aux_idx);
    elseif dim == 2
        data = data(band, loc);
    else
        data = data(:, band, loc);
    end
    data = squeeze(data);
end