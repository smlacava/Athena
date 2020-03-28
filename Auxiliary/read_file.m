%% read_file
% This function is used in the batch mode to read the file containing the
% instruction to execute.
%
% parameters = read_file(dataFile)
%
% input:
%   dataFile is the name of the file (with its path) which contains all the
%       instructions to execute
%
% output:
%   parameters is a cell array which contains all the parameters which have
%       to be used in batch analysis (in order, dataPath, fs, cf, epNum, 
%       epTime, tStart, totBand, measure, Subjects, locations, Index, 
%       MeasureExtraction, EpochsAverage, EpochsAnalysis, IndexCorrelation,
%       StatisticalAnalysis, MeasuresCorrelation, ClassificationData, 
%       Group_IC, Areas_IC, Conservativeness_IC, Areas_EA, Areas_SA, 
%       Conservativeness_SA, Measure1, Measure2, Areas_MC, Group_MC,
%       MergingData, DataType, MergingMeasures, MergingAreas, Subject, 
%       Classification, ClassificationData, DefaultClassification, 
%       TrainPercentage, TreesNumber, FResampleValue, Pruning, 
%       Repetitions, MinimumClassExamples, PCAValue)


function parameters = read_file(dataFile)
    
    params_names = {'dataPath=', 'fs=', 'cf=', 'epNum=', 'epTime=', ...
        'tStart=', 'totBand=', 'measures=', 'Subjects=', 'Locations=', ...
        'Index=', 'MeasureExtraction=', 'EpochsAverage=', ...
        'EpochsAnalysis=', 'IndexCorrelation=', 'StatisticalAnalysis=', ...
        'MeasuresCorrelation=', 'ClassificationData=', 'Group_IC=', ...
        'Areas_IC=', 'Conservativeness_IC=', 'Areas_EA=', 'Areas_SA=', ...
        'Conservativeness_SA=', 'Measure1=', 'Measure2=', 'Areas_MC=', ...
        'Group_MC=', 'MergingData=', 'MergingMeasures=', ...
        'MergingAreas=', 'Subject=', 'Classification=', ...
        'DataType', 'DefaultClassificationParameters=', ...
        'TrainPercentage=', 'TreesNumber=', 'FResampleValue=', ...
        'Pruning=', 'Repetitions=', 'MinimumClassExamples=', ...
        'PCAValue=', 'Evaluation='};
    n_params = length(params_names);
    parameters = cell(n_params, 1);
    
    aux_cases = 1:n_params;
    par_cases = {aux_cases(contains(params_names, 'Conservativeness'))};
    par_cases = [par_cases, [aux_cases(contains(params_names, 'fs')), ...
        aux_cases(contains(params_names, 'epNum')), ...
        aux_cases(contains(params_names, 'epTime')), ...
        aux_cases(contains(params_names, 'tStart')), ...
        aux_cases(contains(params_names, 'Repetitions')), ...
        aux_cases(contains(params_names, 'MinimumClassExamples')), ...
        aux_cases(contains(params_names, 'TrainPercentage')), ...
        aux_cases(contains(params_names, 'TreesNumber')), ...
        aux_cases(contains(params_names, 'MergingAreas')), ...
        aux_cases(contains(params_names, 'FResampleValue')), ...
        aux_cases(contains(params_names, 'PCAValue'))]];
    par_cases = [par_cases, ...
        [aux_cases(contains(params_names, 'measures')), ...
        aux_cases(contains(params_names, 'Areas_')), ...
        aux_cases(contains(params_names, 'Group_')), ...
        aux_cases(contains(params_names, 'MergingMeasures')), ...
        aux_cases(contains(params_names, 'MergingAreas')), ...
        aux_cases(contains(params_names, 'totBand'))]];
    cf = 3;
    par_functions = {@cons_check, @str2double, @split};
    
    
    auxID = fopen(dataFile, 'r');
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        prop = fgetl(auxID);
        for i = 1:n_params
            if contains(prop, params_names{i})
                aux_par = split(prop, '=');
                aux_par = aux_par{2};
                if contains(prop, 'cf=')
                    aux_par = str2double(split(aux_par))';
                    parameters{cf} = aux_par(1:end-1);
                else
                    check = 0;
                    for j = 1:length(par_functions)
                        if not(isempty(find(par_cases{j} == i)))
                            p_f = par_functions{j};
                            parameters{i} = p_f(aux_par);
                            check = 1;
                        end
                    end
                    if check == 0
                        parameters{i} = aux_par;
                    end
                end
            end
        end
    end
    fclose(auxID);
end