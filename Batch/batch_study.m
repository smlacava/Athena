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
    
    % dataPath 1, fs 2, cf 3, epNum 4, epTime 5, tStart 6, totBand 7, 
    % measure 8, Subjects 9, locations 10, Index 11, MeasureExtraction 12, 
    % EpochsAverage 13, EpochsAnalysis 14, IndexCorrelation 15, 
    % StatisticalAnalysis 16, MeasuresCorrelation 17, 
    % ClassificationData 18, Group_IC 19, Areas_IC 20, 
    % Conservativeness_IC 21, Areas_EA 22, Areas_SA 23, 
    % Conservativeness_SA 24, Measure1 25, Measure2 26, Areas_MC 27, 
    % Group_MC 28, MergingData 29, MergingMeasures 30, MergingAreas 31, 
    % Subject 32, RF_Classification 33, DataType 34, 
    % RF_DefaultClassification 35, RF_TrainPercentage 36, 
    % RF_TreesNumber 37, RF_FResampleValue 38, RF_Pruning 39, 
    % RF_Repetitions 40, RF_MinimumClassExamples 41, RF_PCAValue 42, 
    % RF_Evaluation 43, RF_Rejection 44, NN_Classification 45, 
    % NN_DefaultClassificationParameters 46, NN_TrainPercentage 47, 
    % NN_HiddenLayersNumber 48, NN_ValidationValue 49, NN_Repetitions 50, 
    % NN_MinimumClassExamples 51, NN_PCAValue 52, NN_Evaluation 53,
    % NN_Rejection 54
    parameters = read_file(dataFile);
    
    dataPath = path_check(parameters{1});
    cf = parameters{3};
    nBands = length(cf)-1;
    measure = parameters{8};
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
 
    
    if sum(strcmp(parameters{12}, 'true'))
        for m = 1:n_measures
            if strcmp(measure{m}, 'PSDr') && length(parameters{7}) ~= 2
                problem('Invalid total band')
                return
            end
            [type, ~] = type_check(measure{m});
            if strcmpi(measure{m}, 'PSDr') 
                PSDr(parameters{2}, cf, parameters{4}, parameters{5}, ...
                    dataPath, parameters{6}, parameters{7})
            elseif strcmpi(measure{m}, 'offset') || ...
                    strcmpi(measure{m}, 'exponent')
                    cf_bg = [cf(1), cf(end)];
                FOOOFer(parameters{2}, cf_bg, parameters{4}, ...
                    parameters{5}, dataPath, parameters{6}, type)
            else
                connectivity(parameters{2}, cf, parameters{4}, ...
                    parameters{5}, dataPath, parameters{6}, measure{m})
            end
            measure_update_file(parameters{3}, measure{m}, ...
                parameters{7}, dataPath, parameters{2}, parameters{4}, ...
                parameters{5}, parameters{6});
            pause(1)
        end
    end
    
    
    if sum(strcmp(parameters{13}, 'true'))
        if not(exist(parameters{9}, 'file'))
            problem(strcat(parameters{9}, ' file not found'))
            return
        end
        for m = 1:n_measures
            if not(exist(path_check(strcat(path_check(strcat(dataPath, ...
                    measure{m})), 'Epmean')), 'dir'))
                mkdir(path_check(strcat(path_check(strcat(dataPath, ...
                    measure{m})), 'Epmean')))
            end
            locations_file = epmean_and_manage(dataPath, measure{m}, ...
                parameters{9}, parameters{10});
            if exist('auxiliary.txt', 'file')
                auxID = fopen('auxiliary.txt', 'a+');
            elseif exist(strcat(dataPath, 'auxiliary.txt'), 'file')
                auxID = fopen(strcat(dataPath, 'auxiliary.txt'), 'a+');
            end
            management_update_file(strcat(path_check(dataPath), ...
                path_check(measure{m})), locations_file, parameters{9});
        end
    end
    
    if sum(strcmp(parameters{14}, 'true'))
        if not(exist(parameters{10}, 'file'))
            problem(strcat("File ", parameters{10}, " not found"))
            return
        end
        Areas_EA = parameters{22};
        for m = 1:n_measures
            for i = 1:length(Areas_EA)
                epochs_analysis(dataPath, parameters{32}, ...
                    areas_check(Areas_EA{i,1}), measure{m}, ...
                    parameters{4}, nBands, parameters{10})
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
        if exist(parameters{10}, 'file')
            locations = load_data(parameters{10});
            locations = locations(:, 1);
        else
            try
                locations = strcat(dataPath, 'Locations.mat');
            end
        end
    end
    alpha = alpha_levelling(parameters{21}, nBands, length(locations));
    
    for m = 1:n_measures
        if not(exist(managedPath{m}, 'dir')) && ...
                sum([sum(strcmp(parameters{17}, true)), ...
                sum(strcmp(parameters{15}, true)), ...
                sum(strcmp(parameters{16}, true))]) > 0
            problem('Epochs Avarage not computed')
            return
        else
            cd(dataPath)
        
            Subjects = load_data(parameters{9});
            if sum(strcmp(parameters{15}, 'true'))
                if not(exist(parameters{11}, 'file'))
                    problem(strcat("File ", parameters{11}, " not found"))
                    return
                end
                Areas_IC = parameters{20};
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
                        Areas_IC{i})), parameters{19}, '.mat')));
                    subs = {};
                    if strcmp(char_check(parameters{19}), 'PAT')
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
                    parameters{11}, alpha, bg_color, locations, P, RHO, ...
                        length(locations), nBands);
                end
                pause(2)
            end
        end
        
        if sum(strcmp(parameters{16}, 'true'))
            Areas_SA = parameters{23};
            for i = 1:length(Areas_SA)
                saPath = path_check(strcat(managedPath{m}, Areas_SA{i}));
                PAT = strcat(saPath, 'PAT.mat');
                HC = strcat(saPath, 'HC.mat');
                [PAT, ~, locs] = load_data(PAT);
                HC = load_data(HC);
                anType = areas_check(Areas_SA{i,1});
                statistical_analysis(HC, PAT, locs, ....
                    cons_check(parameters{24}), ...
                    dataPath, measure{m}, anType)
            end
        end
        
        if sum(strcmp(parameters{17}, 'true'))
            Areas_MC = parameters{27};
            for i = 1:length(Areas_MC)
                [xData, yData, nLoc, nBands, locs] = ...
                    batch_measures_correlation_settings(parameters{25}, ...
                    parameters{26}, dataPath, Areas_MC{i}, parameters{28});
                if isempty(nBands)
                    return;
                end
                bands = cell(1, nBands);
                for b = 1:nBands
                	bands{1, b} = char_check(strcat("Band ", string(b)));
                end
                measures_correlation(xData, yData, parameters{28}, ...
                    bands, {parameters{25}, parameters{26}}, alpha, ...
                    bg_color, locs, [], [], nLoc, nBands)   
            end
        end
    end
    
    if sum(strcmp(parameters{29}, 'true'))
    	MergingAreas = parameters{31};
        MergingMeasures = parameters{30};
        classification_data_settings(dataPath, MergingAreas, ...
            MergingMeasures, parameters{34});
    end
    
    % RF_Classification 33, RF_DefaultClassification 35, 
    % RF_TrainPercentage 36, RF_TreesNumber 37, RF_FResampleValue 38, 
    % RF_Pruning 39, RF_Repetitions 40, RF_MinimumClassExamples 41, 
    % RF_PCAValue 42, RF_Evaluation 43, RF_Rejection 44
    if sum(strcmp(parameters{33}, 'true'))
        for i = 36:41
            if isnan(parameters{i})
                parameters{i} = [];
            end
        end
        %random_forest(data, n_trees, resample_value, pruning, ...
        %       n_repetitions, min_samples, pca_value, eval_method, ...
        %       split_value, reject_option)
        if strcmpi(parameters{35}, 'true')
            statistics = random_forest(dataPath, 31, 0.5, 'on', ...
                100, 1, 100, 'split', 0.8, 0.5);
        else
            if sum(strcmpi(parameters{39}, {'nan', 'null', 'off'}))
                parameters{39} = 'off';
            end
            statistics = random_forest(dataPath, parameters{37}, ...
                parameters{38}, parameters{39}, parameters{40}, ...
                parameters{41}, parameters{42}, parameters{43}, ...
                parameters{36}, parameters{44});
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
    
    % NN_Classification 45, NN_DefaultClassificationParameters 46, 
    % NN_TrainPercentage 47, NN_HiddenLayersNumber 48, 
    % NN_ValidationValue 49, NN_Repetitions 50, NN_MinimumClassExamples 51, 
    % NN_PCAValue 52, NN_Evaluation 53, NN_Rejection 54
    if sum(strcmp(parameters{45}, 'true'))
        for i = 49:54
            if isnan(parameters{i})
                parameters{i} = [];
            end
        end
        %neural_network(data, n_layers, validation_value, ...
        %    ~, repetitions, min_samples, pca_value, eval_method, ...
        %    training_value, reject_value)
        if strcmpi(parameters{46}, 'true')
            neural_network(dataPath, 10, 0.1, 1, 100, 1, 100, 'split', ...
               0.8, 0.5)
        else
            statistics = neural_network(dataPath, parameters{48}, ...
                parameters{49}, 1, parameters{50}, parameters{51}, ...
                parameters{52}, parameters{53}, parameters{47}, ...
                parameters{54});
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