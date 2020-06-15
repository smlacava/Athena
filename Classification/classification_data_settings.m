%% classification_data_settings
% This function computes the data table for a following classification
% (data classes will be defined in data.group column)
%
% data = classification_data_settings(dataPath, analysis_types, ...
%       measures, data_type)
%
% Input:
%   dataPath is the main folder of the study
%   analysis_types is the list of spatial analysis to include
%   measures is the list of measures to include
%   data_type is the type of data to include (only significant or all)
%
% Output:
%   data is the resulting data table


function data = classification_data_settings(dataPath, analysis_types, ...
    measures, data_type)

    subjects = load_data(strcat(dataPath, 'Subjects.mat'));

    cat_subjects = categorical(subjects(:, end));
    sub_types = categories(cat_subjects);
    nPAT = sum(cat_subjects == sub_types{2});
    nHC = length(cat_subjects)-nPAT;
    
    outPath = path_check(create_directory(dataPath, 'Classification'));
    dataPath = path_check(strcat(path_check(dataPath), 'StatAn'));
    create_data = @significant_data;
    if strcmpi(data_type, 'All')
        dataPath = path_check(strcat(dataPath, 'Data'));
        create_data = @all_data;
    end
    
    cases = define_cases(dataPath, 0);
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
    
    [data, features] = create_data(cases, types, dataPath, features, data);
    features = check_features(features);
    data = array2table(data, 'VariableNames', features);
    save(strcat(outPath, 'Classification_Data.mat'), 'data')
end


function [data, features] = significant_data(cases, types, dataPath, ...
    features, data)

    n_cases = length(cases);
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
                    feature_name = split(feature_name, 'major');
                    features = [features, feature_name{1}];
                end
                data = [data, statAnResult.dataSig];
            end
        end
    end
end


function [data, features] = all_data(cases, types, dataPath, features, ...
    data)

    n_cases = length(cases);
    for i = 1:n_cases
        if logical(sum(strcmpi(cases(i).name, types)))
            load(strcat(dataPath, cases(i).name))
            if not(isempty(statAnData.data))
                if size(statAnData.feature_names, 2) > ...
                        size(statAnData.feature_names, 1)
                    statAnData.feature_names = statAnData.feature_names';
                end
                for f = 1:size(statAnData.feature_names, 1)
                    feature_name = char_check(strtok(cases(i).name, '_'));
                    aux_f = split(statAnData.feature_names{f, :});
                    for ind = 1:length(aux_f)
                        feature_name = strcat(feature_name, aux_f(ind));
                    end
                    features = [features, feature_name];
                end
                data = [data, statAnData.data];
            end
        end
    end
end

function features = check_features(features)
	for i = 1:length(features)
        aux_feature = split(features{i}, '-');
        features{i} = aux_feature{1};
    end
end