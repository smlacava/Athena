%% update_file
% This function update the text file which contains the study parameters
%
% update_file(dataFile, updates)
%
% input:
%   dataFile is the name (with its path) of the file to update
%   updates is the cell array which contais the updates (for example, 
%       {'parameter_1=value_1', 'parameter_2'=value_2'})


function update_file(dataFile, updates)
    params_names = {'dataPath=', 'fs=', 'cf=', 'epNum=', 'epTime=', ...
        'tStart=', 'totBand=', 'measures=', 'Subjects=', 'Locations=', ...
        'Index=', 'MeasureExtraction=', 'EpochsAverage=', ...
        'EpochsAnalysis=', 'IndexCorrelation=', 'StatisticalAnalysis=', ...
        'MeasuresCorrelation=', 'ClassificationData=', 'Group_IC=', ...
        'Areas_IC=', 'Conservativeness_IC=', 'Areas_EA=', 'Areas_SA=', ...
        'Conservativeness_SA=', 'Measure1=', 'Measure2=', 'Areas_MC=', ...
        'Group_MC=', 'ClassificationData=', 'MergingMeasures=', ...
        'MergingAreas=', 'Subject=', 'Classification=', ...
        'DefaultClassificationParameters=', 'TrainPercentage=', ...
        'TreesNumber=', 'BaggingValue=', 'PruningDepth=', ...
        'Repetitions=', 'MinimumClassExamples=', 'PCAValue='};
    n_params = length(params_names);
    params = cell(1, n_params);
    
    if exist(dataFile, 'file')
        auxID = fopen(dataFile, 'r');
        fseek(auxID, 0, 'bof');
        while ~feof(auxID)
            prop = fgetl(auxID);
            for i = 1:n_params
                if contains(prop, params_names{i})
                    aux_par = split(prop, '=');
                    params{i} = aux_par{2};
                end
            end
        end
        fclose(auxID);
    end
    
    for i = 1:length(updates)
        for j = 1:n_params
            if contains(updates{i}, params_names{j})
                aux_par = split(updates{i}, '=');
                params{j} = aux_par{2};
            end
        end
    end
    
    auxID = fopen(dataFile, 'w');
    fprintf(auxID, 'STUDY PARAMETERS');
    for i = 1:n_params
        if not(isempty(params{i}))
            fprintf(auxID, strcat('\n', params_names{i}, '%s'), params{i});
        end
    end
    fclose(auxID);
end
