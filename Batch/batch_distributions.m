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
    format = search_parameter(parameters, 'format');
    dataPath = search_parameter(parameters, 'dataPath');
    measure = search_parameter(parameters, 'Distributions_Measure');
    band = search_parameter(parameters, 'Distributions_Band');
    location = search_parameter(parameters, 'Distributions_Location');
    parameter = search_parameter(parameters, 'Distributions_Parameter');
    sub_types = search_parameter(parameters, 'subjects_types');
    band_name = search_parameter(parameters, 'frequency_bands');
    band_name = band_name{band};
    
    [area, check] = batch_check_area(location);
    measure_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), area));
    
    [PAT, ~, locs] = load_data(strcat(measure_path, 'Second.mat'));
    HC = load_data(strcat(measure_path, 'First.mat'));
    
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
    
    distributions_scatterplot(HC, PAT, measure, sub_types, ...
        location, band_name, parameter)
    if str2double(search_parameter(parameters, 'save_figures')) == 1
        outDir = create_directory(dataPath, 'Figures');
        if strcmp(format, '.fig')
            savefig(char_check(strcat(path_check(outDir), ...
                'Distribution_', measure, '_', location, '_', ...
                band_name, '_', parameter, format)));
        else
            Image = getframe(gcf);
            imwrite(Image.cdata, char_check(strcat(path_check(outDir), ...
                'Distribution_', measure, '_', location, '_', ...
                band_name, '_', parameter, format)));
        end
    end
end