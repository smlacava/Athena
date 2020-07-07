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
    MEASURES = ["PLV", "PLI", "AEC", "AECo", "offset", "exponent", ...
        "PSDr", "coherence"];
    true = ["True", "true", "TRUE", "t", "1", "OK", "ok"];
    bg_color = [1 1 1];
    
    % dataPath, fs, cf, epNum, epTime, tStart, totBand, measure, Subjects, 
    % locations, Index, MeasureExtraction, EpochsAverage, EpochsAnalysis, 
    % IndexCorrelation, StatisticalAnalysis, MeasuresCorrelation, 
    % ClassificationData, Group_IC, Areas_IC, Conservativeness_IC, 
    % Areas_EA, Areas_SA, Conservativeness_SA, Measure1, Measure2, 
    % Areas_MC, Group_MC, MergingData, MergingMeasures, MergingAreas, 
    % Subject, RF_Classification, DataType, RF_DefaultClassification, 
    % RF_TrainPercentage, RF_TreesNumber, RF_FResampleValue, RF_Pruning, 
    % RF_Repetitions, RF_MinimumClassExamples, RF_PCAValue, RF_Evaluation, 
    % RF_Rejection, NN_Classification, NN_DefaultClassificationParameters, 
    % NN_TrainPercentage, NN_HiddenLayersNumber, NN_ValidationValue, 
    % NN_Repetitions, NN_MinimumClassExamples, NN_PCAValue, NN_Evaluation,
    % NN_Rejection
    parameters = read_file(dataFile);
    
    %% Preprocessing and Extraction
    dataPath = path_check(search_parameter(parameters, 'dataPath'));
    cf = search_parameter(parameters, 'cf');
    nBands = length(cf)-1;
    measure = search_parameter(parameters, 'measures');
    n_measures = length(measure);
    measurePath = cell(n_measures, 1);
    statTool = 'Statistics and Machine Learning Toolbox';
    deepTool = 'Deep Learning Toolbox';
    
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
        measurePath{m} = path_check(strcat(dataPath, measure{m}));
        if not(exist(measurePath{m}, 'dir'))
            mkdir(measurePath{m});
        end
    end
 
    
    if sum(strcmp(search_parameter(parameters, 'MeasureExtraction'), ...
        'true'))
        for m = 1:n_measures
            if strcmp(measure{m}, 'PSDr') && ...
                    length(search_parameter(parameters, 'totBand')) ~= 2
                problem('Invalid total band')
                return
            end
            [type, ~] = type_check(measure{m});
            if strcmpi(measure{m}, 'PSDr') 
                PSDr(search_parameter(parameters, 'fs'), cf, ...
                    search_parameter(parameters, 'epNum'), ...
                    search_parameter(parameters, 'epTime'), ...
                    dataPath, search_parameter(parameters, 'tStart'), ...
                    search_parameter(parameters, 'totBand'))
            elseif strcmpi(measure{m}, 'offset') || ...
                    strcmpi(measure{m}, 'exponent')
                    cf_bg = [cf(1), cf(end)];
                FOOOFer(search_parameter(parameters, 'fs'), cf_bg, ...
                    search_parameter(parameters, 'epNum'), ...
                    search_parameter(parameters, 'epTime'), dataPath, ...
                    search_parameter(parameters, 'tStart'), type)
            else
                connectivity(search_parameter(parameters, 'fs'), cf, ...
                    search_parameter(parameters, 'epNum'), ...
                    search_parameter(parameters, 'epTime'), dataPath, ...
                    search_parameter(parameters, 'tStart'), measure{m})
            end
            measure_update_file(cf, measure{m}, ...
                search_parameter(parameters, 'totBand'), dataPath, ...
                search_parameter(parameters, 'fs'), ...
                search_parameter(parameters, 'epNum'), ...
                search_parameter(parameters, 'epTime'), ...
                search_parameter(parameters, 'tStart'));
            pause(1)
        end
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
                search_parameter(parameters, 'locations'));
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
  
    %% Analysis    
    if sum(strcmp(search_parameter(parameters, 'EpochsAnalysis'), 'true'))
        batch_epochs_analysis(parameters, dataPath, measure{m}, nBands, ...
            n_measures);
    end
    
    managedPath = cell(n_measures, 1);
    for m = 1:n_measures
        managedPath{m} = path_check(strcat(measurePath{m}, 'Epmean'));
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

    
    for m = 1:n_measures
        if not(exist(managedPath{m}, 'dir')) && ...
                sum([sum(strcmp(search_parameter(parameters, ...
                'MeasuresCorrelation'), true)), ...
                sum(strcmp(search_parameter(parameters, ...
                'IndexCorrelation'), true)), ...
                sum(strcmp(search_parameter(parameters, ...
                'UTest'), true)), ...
                sum(strcmp(search_parameter(parameters, ...
                'ScatterAnalysis'), true)), ...
                sum(strcmp(search_parameter(parameters, ...
                'DistributionsAnalysis'), true)), ...
                sum(strcmp(search_parameter(parameters, ...
                'HistogramAnalysis'), true))]) > 0
            problem('Epochs Avarage not computed')
            return
        else
            cd(dataPath)
        
            Subjects = load_data(search_parameter(parameters, 'Subjects'));
            if sum(strcmp(search_parameter(parameters, ...
                    'IndexCorrelation'), 'true'))
                if search_ext_toolbox(statTool)
                    batch_index_correlation(parameters, managedPath{m}, ...
                        measure{m}, Subjects, nBands, locations, bg_color);
                end
            end
        end
        
        if sum(strcmp(search_parameter(parameters, ...
                'UTest'), 'true'))
            Areas_UT = search_parameter(parameters, 'Areas_UT');
            for i = 1:length(Areas_UT)
                saPath = path_check(strcat(managedPath{m}, Areas_UT{i}));
                PAT = strcat(saPath, 'Second.mat');
                HC = strcat(saPath, 'First.mat');
                [PAT, ~, locs] = load_data(PAT);
                HC = load_data(HC);
                anType = areas_check(Areas_UT{i,1});
                statistical_analysis(HC, PAT, locs, ....
                    cons_check(search_parameter(parameters, ...
                    'Conservativeness_UT')), measurePath{m}, ...
                    measure{m}, anType, sub_types)
            end
        end
        
        if sum(strcmp(search_parameter(parameters, ...
                'MeasuresCorrelation'), 'true'))
            batch_measures_correlation(parameters, dataPath, locations, ...
                bg_color)
        end
        
        if strcmpi(search_parameter(parameters, 'ScatterAnalysis'), 'true')
            batch_scatter(parameters);
        end
        
        if strcmpi(search_parameter(parameters, ...
                'DistributionsAnalysis'), 'true')
            batch_distributions(parameters);
        end
        if strcmpi(search_parameter(parameters, ...
                'HistogramAnalysis'), 'true')
            batch_histogram(parameters);
        end
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
end