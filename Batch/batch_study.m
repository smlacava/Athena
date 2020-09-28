%% batch_study
% This function computes the batch study by executing the analysis by using 
% parameters selected in a text file
%
% batch_study(dataFile)
%
% input:
%   dataFile is the name of the file (with its path) which contains all the
%       parameters to use in the study


function batch_study(dataFile)
    MEASURES = Athena_measures_list();
    true_val = ["True", "true", "TRUE", "t", "1", "OK", "ok"];
    bg_color = [1 1 1];
    parameters = read_file(dataFile);
    statTool = 'Statistics and Machine Learning Toolbox';
    deepTool = 'Deep Learning Toolbox';
    
    %% Preprocessing and Extraction
    dataPath = path_check(search_parameter(parameters, 'dataPath'));
    cf = search_parameter(parameters, 'cf');
    nBands = length(cf)-1;
    measure = search_parameter(parameters, 'measures');
    filter_file = search_parameter(parameters, 'filter_file');
    if isempty(filter_file)
        filter_name = 'athena_filter';
    else
        filter_name = batch_check_filter(filter_file);
    end
    n_measures = length(measure);
    measuresPath = cell(n_measures, 1);
    save_check_fig = sum(strcmpi(search_parameter(parameters, ...
        'save_figures'), true_val));
    format = search_parameter(parameters, 'format');
    if isempty(save_check_fig)
        save_check_fig = 0;
    end
    
    if not(exist(dataPath, 'dir'))
        problem(strcat('Directory ', dataPath, ' not found'))
        return
    end
    for m = 1:n_measures
        if strcmpi(measure{m}, 'AECc')
            measure{m} = 'AECo';
        end
        if not(sum(strcmpi(measure{m}, MEASURES)))
            problem(strcat(measure{m}, ' is an invalid measure'))
            return
        end
        measuresPath{m} = path_check(strcat(dataPath, measure{m}));
        if not(exist(measuresPath{m}, 'dir'))
            mkdir(measuresPath{m});
        end
    end
 
    
    if sum(strcmp(search_parameter(parameters, 'MeasureExtraction'), ...
        true_val))
        batch_measureExtraction(parameters, dataPath, measure, cf);
    end
    
    sub_types = {'First'; 'Second'};
    if sum(strcmp(search_parameter(parameters, 'EpochsAverage'), 'true'))
        if not(exist(search_parameter(parameters, 'Subjects'), 'file'))
            problem(strcat(search_parameter(parameters, 'Subjects'), ...
                ' file not found'))
            return
        end
        for m = 1:n_measures
            if not(exist(path_check(strcat(path_check(strcat(dataPath, ...
                    measure{m})), 'Epmean')), 'dir'))
                mkdir(path_check(strcat(path_check(strcat(dataPath, ...
                    measure{m})), 'Epmean')))
            end
            [locations_file, sub_types] = epmean_and_manage(dataPath, ...
                measure{m}, search_parameter(parameters, 'Subjects'), ...
                search_parameter(parameters, 'Locations'));
            if exist('auxiliary.txt', 'file')
                auxID = fopen('auxiliary.txt', 'a+');
            elseif exist(strcat(dataPath, 'auxiliary.txt'), 'file')
                auxID = fopen(strcat(dataPath, 'auxiliary.txt'), 'a+');
            end
            management_update_file(strcat(path_check(dataPath), ...
                path_check(measure{m})), locations_file, ...
                search_parameter(parameters, 'Subjects'));
        end
    end
    parameters = [parameters, 'subjects_types', {sub_types}];
    bands_names = [];
    for i = 1:length(cf)-1
        bands_names = [bands_names; string(strcat(string(cf(i)), "-", ...
            string(cf(i+1)), " Hz"))];
    end
    bands_names = cellstr(bands_names);
    parameters = [parameters, 'frequency_bands', {bands_names}];
  
    %% Statistical and Visual Analysis    
    if sum(strcmp(search_parameter(parameters, ...
            'NetworkMetricsAnalysis'), 'true'))
        batch_network_measure(parameters)
    end
    if sum(strcmp(search_parameter(parameters, 'EpochsAnalysis'), 'true'))
        batch_epochs_analysis(parameters, dataPath, measure{m}, nBands, ...
            n_measures, save_check_fig, format);
    end
    
    managedPath = cell(n_measures, 1);
    for m = 1:n_measures
        managedPath{m} = batch_measurePath(dataPath, measure{m});
    end
    
    if exist('locations_file', 'var') && ischar(locations_file)
        locations = load_data(locations_file);
    else
        if exist(search_parameter(parameters, 'Locations'), 'file')
            locations = load_data(search_parameter(parameters, ...
                'Locations'));
            locations = locations(:, 1);
        else
            try
                locations = strcat(dataPath, 'Locations.mat');
            catch
            end
        end
    end

    
    cd(dataPath)
    if sum(strcmp(search_parameter(parameters, ...
            'UTest'), 'true'))
        Areas_UT = search_parameter(parameters, 'Areas_UT');
        for i = 1:length(Areas_UT)
            saPath = measurePath(dataPath, search_parameter(parameters, ...
                'UTestMeasure'), Areas_UT{i});
            PAT = strcat(path_check(saPath), 'Second.mat');
            HC = strcat(path_check(saPath), 'First.mat');
            [PAT, ~, locs] = load_data(PAT);
            HC = load_data(HC);
            anType = areas_check(Areas_UT{i,1});
            statistical_analysis(HC, PAT, locs, ....
                cons_check(search_parameter(parameters, ...
                'Conservativeness_UT')), saPath, ...
                search_parameter(parameters, 'UTestMeasure'), anType, ...
                sub_types)
        end
    end
    
    if strcmpi(search_parameter(parameters, 'ScatterAnalysis'), 'true')
        batch_scatter(parameters);
    end
    
    if strcmpi(search_parameter(parameters, ...
            'DistributionsAnalysis'), 'true')
        batch_distributions(parameters);
    end
    if strcmpi(search_parameter(parameters, ...
            'DescriptiveAnalysis'), 'true')
        batch_descriptive_analysis(parameters);
    end
    if strcmpi(search_parameter(parameters, ...
            'HistogramAnalysis'), 'true')
        batch_histogram(parameters);
    end
    
    %% Classification 
    if sum(strcmp(search_parameter(parameters, 'MergingData'), 'true'))
    	MergingAreas = search_parameter(parameters, 'MergingAreas');
        MergingMeasures = search_parameter(parameters, 'MergingMeasures');
        data = classification_data_settings(dataPath, MergingAreas, ...
            MergingMeasures, search_parameter(parameters, 'DataType'));
        pca_value = search_parameter(parameters, 'PCAValue');
        if not(isempty(pca_value))
            if pca_value < 1 && pca_value > 0
                pca_value = pca_value*100;
            end
            [data] = reduce_predictors(data, pca_value);
            fpca = figure('Color', [1 1 1], 'NumberTitle', 'off', ...
                'Name', 'Statistical Analysis - Significant Results');
            pca = uitable(fpca, 'Data', ...
                cellstr(data.Properties.VariableNames(2:end))', ...
                'Position', [20 20 525 375], 'ColumnName', {'Features'});
            save(strcat(path_check(dataPath), 'Classification', ...
                filesep, 'Classification_Data.mat'), 'data')
        end
    end
    
    if sum(strcmp(search_parameter(parameters, 'RF_Classification'), ...
            'true')) && search_ext_toolbox(....
            'Statistics and Machine Learning Toolbox') == 1
        batch_random_forest(parameters);
    end
    
    if sum(strcmp(search_parameter(parameters, 'NN_Classification'), ...
            'true')) && search_ext_toolbox('Deep Learning Toolbox') == 1
        batch_neural_network(parameters);
    end
    
    %% Correlation Analysis
    for m = 1:n_measures
        if not(exist(managedPath{m}, 'dir')) && ...
                sum([sum(strcmp(search_parameter(parameters, ...
                'MeasuresCorrelation'), true_val)), ...
                sum(strcmp(search_parameter(parameters, ...
                'IndexCorrelation'), true_val))]) > 0
            problem('Epochs Avarage not computed')
            return
        else
            cd(dataPath)
        
            Subjects = load_data(search_parameter(parameters, 'Subjects'));
            if sum(strcmp(search_parameter(parameters, ...
                    'IndexCorrelation'), 'true'))
                if search_ext_toolbox(statTool)
                    batch_index_correlation(parameters, managedPath{m}, ...
                        measure{m}, Subjects, nBands, locations, ...
                        bg_color, save_check_fig, format);
                end
            end
        end
        
        if sum(strcmp(search_parameter(parameters, ...
                'MeasuresCorrelation'), 'true'))
            batch_measures_correlation(parameters, dataPath, locations, ...
                bg_color, save_check_fig, format)
        end  
    end
    success()
end