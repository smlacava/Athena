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
    MEASURES = ["PLV", "PLI", "AEC", "AECo", "offset", "exponent", "PSDr"];
    true = ["True", "true", "TRUE", "t", "1", "OK", "ok"];
    bg_color = [0.67 0.98 0.92];
    
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
            locations_file = epmean_and_manage(dataPath, measure{m}, ...
                search_parameter(parameters, 'Subjects'), ...
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
  
    %% Analysis    
    if sum(strcmp(search_parameter(parameters, 'EpochsAnalysis'), 'true'))
        if not(exist(search_parameter(parameters, 'locations'), 'file'))
            problem(strcat("File ", ...
                search_parameter(parameters, 'locations'), " not found"))
            return
        end
        Areas_EA = search_parameter(parameters, 'Areas_EA');
        for m = 1:n_measures
            for i = 1:length(Areas_EA)
                epochs_analysis(dataPath, ...
                    search_parameter(parameters, 'Subject'), ...
                    areas_check(Areas_EA{i,1}), measure{m}, ...
                    search_parameter(parameters, 'epNum'), nBands, ...
                    search_parameter(parameters, 'locations'))
            end
        end
    end
    
    managedPath = cell(n_measures, 1);
    for m = 1:n_measures
        managedPath{m} = path_check(strcat(measurePath{m}, 'Epmean'));
    end
    if exist('locations_file', 'var') && ischar(locations_file)
        locations = load_data(locations_file);
    else
        if exist(search_parameter(parameters, 'locations'), 'file')
            locations = load_data(search_parameter(parameters, ...
                'locations'));
            locations = locations(:, 1);
        else
            try
                locations = strcat(dataPath, 'Locations.mat');
            catch
            end
        end
    end
    alpha = alpha_levelling(search_parameter(parameters, ...
        'Conservativeness_IC'), nBands, length(locations));

    
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
                'DistributionsAnalysis'), true))]) > 0
            problem('Epochs Avarage not computed')
            return
        else
            cd(dataPath)
        
            Subjects = load_data(search_parameter(parameters, 'Subjects'));
            if sum(strcmp(search_parameter(parameters, ...
                    'IndexCorrelation'), 'true'))
                if not(exist(search_parameter(parameters, 'Index'), ...
                        'file'))
                    problem(strcat("File ", ...
                        search_parameter(parameters, 'Index'), ...
                        " not found"))
                    return
                end
                Areas_IC = search_parameter(parameters, 'Areas_IC');
                for i = 1:length(Areas_IC)
                    [data, ~, locs] = load_data(strcat(path_check(...
                        strcat(managedPath{m}, Areas_IC{i})), 'PAT.mat'));
                    if length(size(data)) == 3
                        nBands = size(data, 2);
                    else
                        nBands = 1;
                    end
                    RHO = zeros(length(locs), nBands);
                    P = RHO;
                    bands = string();
                    for j = 1:nBands
                        bands = [bands; strcat('Band', string(j))];
                    end
                    bands(1, :) = [];
                    bands = cellstr(bands);
                    [data, ~, locations] = load_data(char_check(strcat(...
                        path_check(strcat(managedPath{m}, ...
                        Areas_IC{i})), search_parameter(parameters, ...
                        'Group_IC'), '.mat')));
                    subs = {};
                    if strcmp(char_check(search_parameter(parameters, ...
                        'Group_IC')), 'PAT')
                        for s = 1:length(Subjects)
                            if patient_check(char_check(Subjects(s, end)))
                                subs = [subs, char_check(Subjects(s, 1))];
                            end
                        end
                    else
                        for s = 1:length(Subjects)
                            if not(patient_check(char_check(...
                                    Subjects(s, end))))
                                subs = [subs, char_check(Subjects(s, 1))];
                            end
                        end
                    end
                    index_correlation(data, subs, bands, measure{m}, ...
                        search_parameter(parameters, 'Index'), alpha, ...
                        bg_color, locations, P, RHO, length(locations), ...
                        nBands);
                end
                pause(2)
            end
        end
        
        if sum(strcmp(search_parameter(parameters, ...
                'UTest'), 'true'))
            Areas_UT = search_parameter(parameters, 'Areas_UT');
            for i = 1:length(Areas_UT)
                saPath = path_check(strcat(managedPath{m}, Areas_UT{i}));
                PAT = strcat(saPath, 'PAT.mat');
                HC = strcat(saPath, 'HC.mat');
                [PAT, ~, locs] = load_data(PAT);
                HC = load_data(HC);
                anType = areas_check(Areas_UT{i,1});
                statistical_analysis(HC, PAT, locs, ....
                    cons_check(search_parameter(parameters, ...
                    'Conservativeness_UT')), dataPath, measure{m}, anType)
            end
        end
        
        if sum(strcmp(search_parameter(parameters, ...
                'MeasuresCorrelation'), 'true'))
            Areas_MC = search_parameter(parameters, 'Areas_MC');
            for i = 1:length(Areas_MC)
                [xData, yData, nLoc, nBands, locs] = ...
                    batch_measures_correlation_settings(...
                        search_parameter(parameters, 'Measure1'), ...
                        search_parameter(parameters, 'Measure2'), ...
                        dataPath, Areas_MC{i}, ...
                        search_parameter(parameters, 'Group_MC'));
                if isempty(nBands)
                    return;
                end
                bands = cell(1, nBands);
                for b = 1:nBands
                	bands{1, b} = char_check(strcat("Band ", string(b)));
                end
                measures_correlation(xData, yData, ...
                    search_parameter(parameters, 'Group_MC'), bands, ...
                    {search_parameter(parameters, 'Measure1'), ...
                    search_parameter(parameters, 'Measure2')}, alpha, ...
                    bg_color, locs, [], [], nLoc, nBands)   
            end
        end
        
        if strcmpi(search_parameter(parameters, 'ScatterAnalysis'), 'true')
            batch_scatter(parameters);
        end
        
        if strcmpi(search_parameter(parameters, ...
                'DistributionsAnalysis'), 'true')
            batch_distributions(parameters);
        end
    end
    
    %% Classification 
    if sum(strcmp(search_parameter(parameters, 'MergingData'), 'true'))
    	MergingAreas = search_parameter(parameters, 'MergingAreas');
        MergingMeasures = search_parameter(parameters, 'MergingMeasures');
        classification_data_settings(dataPath, MergingAreas, ...
            MergingMeasures, search_parameter(parameters, 'DataType'));
    end
    
    if sum(strcmp(search_parameter(parameters, 'RF_Classification'), ...
            'true'))
        %random_forest(data, n_trees, resample_value, pruning, ...
        %       n_repetitions, min_samples, pca_value, eval_method, ...
        %       split_value, reject_option)
        if strcmpi(search_parameter(parameters, ...
                'RF_DefaultClassification'), 'true')
            statistics = random_forest(dataPath, 31, 0.5, [], ...
                100, 1, 100, 'split', 0.8, 0.5);
        else
            statistics = random_forest(dataPath, ...
                search_parameter(parameters, 'RF_TreesNumber'), ...
                search_parameter(parameters, 'RF_FResampleValue'), ...
                [], search_parameter(parameters, 'RF_Repetitions'), ...
                search_parameter(parameters, ...
                'RF_MinimumClassExamples'), ...
                search_parameter(parameters, 'RF_PCAValue'), ...
                search_parameter(parameters, 'RF_Evaluation'), ...
                search_parameter(parameters, 'RF_TrainPercentage'), ...
                search_parameter(parameters, 'RF_Rejection'));
        end
        resultDir = strcat(path_check(dataPath), 'Classification');
        if not(exist(resultDir, 'dir'))
            mkdir(resultDir);
        end
        if sum(strcmp(parameters{45}, 'true'))
            save(strcat(path_check(resultDir), 'StatisticsRF.mat'), ...
                'statistics')
        else
           save(strcat(path_check(resultDir), 'Statistics.mat'), ...
                'statistics')
        end
    end
    
    if sum(strcmp(search_parameter(parameters, 'NN_Classification'), ...
        'true'))
        %neural_network(data, n_layers, validation_value, ...
        %    ~, repetitions, min_samples, pca_value, eval_method, ...
        %    training_value, reject_value)
        if strcmpi(search_parameter(parameters, ...
                'NN_DefaultClassificationParameters'), 'true')
            neural_network(dataPath, 10, 0.1, 1, 100, 1, 100, 'split', ...
               0.8, 0.5)
        else
            statistics = neural_network(dataPath, ...
                search_parameter(parameters, 'NN_HiddenLayersNumber'), ...
                search_parameter(parameters, 'NN_ValidationValue'), 1, ...
                search_parameter(parameters, 'NN_Repetitions'), ...
                search_parameter(parameters, ...
                'NN_MinimumClassExamples'), ...
                search_parameter(parameters, 'NN_PCAValue'), ...
                search_parameter(parameters, 'NN_Evaluation'), ...
                search_parameter(parameters, 'NN_TrainPercentage'), ...
                search_parameter(parameters, 'NN_Rejection'));
        end
        resultDir = strcat(path_check(dataPath), 'Classification');
        if not(exist(resultDir, 'dir'))
            mkdir(resultDir);
        end
        if sum(strcmp(parameters{45}, 'true'))
            save(strcat(path_check(resultDir), 'StatisticsNN.mat'), ...
                'statistics')
        else
            save(strcat(path_check(resultDir), 'Statistics.mat'), ...
                'statistics')
        end
    end
end