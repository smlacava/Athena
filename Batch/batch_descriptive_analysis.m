%% batch_descriptive_statistics
% This function is used by the batch study to compute the descriptive
% statistical analysis.
%
% batch_descriptive_analysis(parameters)
% 
% input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study

function batch_descriptive_analysis(parameters)
    format = search_parameter(parameters, 'format');
    dataPath = search_parameter(parameters, 'dataPath');
    measure = search_parameter(parameters, 'Descriptive_Measure');
    band = search_parameter(parameters, 'Descriptive_Band');
    location = search_parameter(parameters, 'Descriptive_Location');
    sub_types = search_parameter(parameters, 'subjects_types');
    band_name = batch_define_bands(parameters, measure);
    band_name = band_name{band};
    
    [area, check] = batch_check_area(location);
    measure_path = measurePath(dataPath, measure, area);
    
    [~, ~, locs] = load_data(strcat(measure_path, 'Second.mat'));
    if isempty(locs)
        [~, ~, locs] = load_data(strcat(measure_path, 'First.mat'));
    end
    if isempty(locs)
        problem('Files for Descriptive Statistical Analysis not found')
        return
    end
    
    if check == 1
        idx_loc = 1;
    else
        for i = 1:length(locs)
            if strcmpi(locs{i}, location)
                idx_loc = i;
                break;
            end
        end
    end
    
    descriptive_statistical_analysis(dataPath, measure, ...
        area, band, idx_loc, sub_types, location, band_name)
    if str2double(search_parameter(parameters, 'save_figures')) == 1
        outDir = create_directory(dataPath, 'Figures');
        if strcmp(format, '.fig')
            savefig(char_check(strcat(path_check(outDir), ...
                'Descriptive_Statistical_Analysis_', measure, '_', ...
                location, '_', band_name, format)));
        else
            Image = getframe(gcf);
            imwrite(Image.cdata, char_check(strcat(path_check(outDir), ...
                'Descriptive_Statistical_Analysis_', measure, '_', ...
                location, '_', band_name, format)));
        end
    end
end