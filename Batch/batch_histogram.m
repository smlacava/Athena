%% batch_histogram
% This function is used by the batch study to show and to compare the 
% histogram of the distributions of two groups of subjects
%
% batch_distributions(parameters)
% 
% input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study


function batch_histogram(parameters)
    format = search_parameter(parameters, 'format');
    dataPath = search_parameter(parameters, 'dataPath');
    measure = search_parameter(parameters, 'Histogram_Measure');
    band = search_parameter(parameters, 'Histogram_Band');
    location = search_parameter(parameters, 'Histogram_Location');
    bins = search_parameter(parameters, 'Histogram_Resolution');
    sub_types = search_parameter(parameters, 'subjects_types');
    band_name = search_parameter(parameters, 'frequency_bands');
    band_name = band_name{band};
    
    aux_bins = str2double(bins);
    if isnan(aux_bins)
        if strcmpi(bins, 'low')
            bins = 5;
        elseif strcmpi(bins, 'medium')
            bins = 10;
        else
            bins = 30;
        end
    else
        bins = aux_bins;
    end
    
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
    
    distributions_histogram(HC, PAT, measure, sub_types, ...
        location, band_name, bins)
    if str2double(search_parameter(parameters, 'save_figures')) == 1
        outDir = create_directory(dataPath, 'Figures');
        if strcmp(format, '.fig')
            savefig(char_check(strcat(path_check(outDir), ...
                'Histogram_', measure, '_', location, '_', band_name, ...
                format)));
        else
            Image = getframe(gcf);
            imwrite(Image.cdata, char_check(strcat(path_check(outDir), ...
                'Histogram_', measure, '_', location, '_', band_name, ...
                format)));
        end
    end
end