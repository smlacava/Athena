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
    
    %dataPath, fs, cf, epNum, epTime, tStart, totBand, measure, Subjects, 
    %locations, Index, MeasureExtraction, EpochsAverage, EpochsAnalysis, 
    %IndexCorrelation, StatisticalAnalysis, MeasuresCorrelation, 
    %ClassificationData, Group_IC, Areas_IC, Conservativeness_IC, Areas_EA, 
    %Areas_SA, Conservativeness_SA, Measure1, Measure2, Areas_MC, Group_MC, 
    %MergingData, MergingMeasures, MergingAreas, Subject, Classification, 
    %DataType, DefaultClassification, TrainPercentage, 
    %TreesNumber, FResampleValue, Pruning, Repetitions, 
    %MinimumClassExamples, PCAValue, Evaluation, Rejection
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
    
    if sum(strcmp(parameters{33}, 'true'))
        for i = 36:41
            if isnan(parameters{i})
                parameters{i} = [];
            end
        end
        if sum(strcmpi(parameters{39}, {'nan', 'null', 'off'}))
            parameters{39} = 'off';
        end
        statistics = random_forest(dataPath, parameters{37}, ...
            parameters{38}, parameters{39}, parameters{40}, ...
            parameters{41}, parameters{42}, parameters{43}, ...
            parameters{36}, parameters{44});
        resultDir = strcat(path_check(dataPath), 'Classification');
        if not(exist(resultDir, 'dir'))
            mkdir(resultDir);
        end
        save(strcat(path_check(resultDir), 'Statistics.mat'), 'statistics')
    end
end