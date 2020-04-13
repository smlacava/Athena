%% batch_distributions
% This function is used by the batch study to show and to compare the 
% distributions of two groups of subjects
%
% batch_distributions(parameters)
% 
% input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study


function batch_distributions(parameters)

    dataPath = search_parameter(parameters, 'dataPath');
    measure = search_parameter(parameters, 'Distributions_Measure');
    band = search_parameter(parameters, 'Distributions_Band');
    location = search_parameter(parameters, 'Distributions_Location');
    parameter = search_parameter(parameters, 'Distributions_Parameter');
    
    [area, check] = batch_check_area(location);
    measure_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), area));
    
    [PAT, ~, locs] = load_data(strcat(measure_path, 'PAT.mat'));
    HC = load_data(strcat(measure_path, 'HC.mat'));
    
    if check == 0
        idx_loc = 1;
    else
        for i = 1:length(locs)
            if strcmpi(locs{i}, location)
                idx_loc = i;
                break;
            end
        end
    end
    
    PAT = PAT(:, band, idx_loc);
    HC = HC(:, band, idx_loc);
    
    distributions_scatterplot(HC, PAT, measure, {'Group 0', 'Group 1'}, ...
        location, band, parameter)
end