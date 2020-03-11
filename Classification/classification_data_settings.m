%% classification_data_settings
% This function computes the data table for a following classification
% (data classes will be defined in data.group column)
%
% classification_data_settings(dataPath, analysis_types, measures)
%
% input:
%   dataPath is the main folder of the study
%   analysis_types is the list of spatial analysis to include
%   measures is the list of measures to include


function classification_data_settings(dataPath, analysis_types, measures)
    dataPath = path_check(dataPath);
    subjects = load_data(strcat(dataPath, 'Subjects.mat'));
    if isstring(subjects(:, end))
        subjects = str2double(subjects(:, end));
    end
    nPAT = sum(subjects(:, end));
    nHC = length(subjects)-nPAT;
    outPath = path_check(strcat(dataPath, 'Classification'));
    dataPath = path_check(strcat(dataPath, 'statAn'));
    cases = define_cases(dataPath, 0);
    n_cases = length(cases);
    data = [ones(nPAT, 1); zeros(nHC, 1)];
    features = {'group'};
    
    n_analysis = length(analysis_types);
    n_measures = length(measures);
    types = cell(1, n_measures*n_analysis);
    for i = 1:n_measures
        for j = 1:n_analysis
            types{1, (i-1)*n_analysis+j} = char_check(...
                strcat(measures{i}, '_', analysis_types{j}, '.mat'));
        end
    end
    
    for i = 1:n_cases
        if logical(sum(strcmpi(cases(i).name, types)))
            load(strcat(dataPath, cases(i).name))
            if not(isempty(statAnResult.dataSig))
                if size(statAnResult.Psig, 2) > size(statAnResult.Psig, 1)
                    statAnResult.Psig = statAnResult.Psig';
                end
                for f = 1:size(statAnResult.Psig, 1)
                    feature_name = char_check(strtok(cases(i).name, '_'));
                    aux_f = split(statAnResult.Psig(f, :));
                    for ind = 1:length(aux_f)
                        feature_name = strcat(feature_name, aux_f(ind));
                    end
                    features = [features, feature_name];
                end
                data = [data, statAnResult.dataSig];
            end
        end
    end
    data = array2table(data, 'VariableNames', features);
    
    if not(exist(outPath, 'dir'))
        mkdir(outPath)
    end
    save(strcat(outPath, 'Classification_Data.mat'), 'data')
end