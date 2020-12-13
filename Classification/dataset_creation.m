%% dataset_creation
% This function computes the data table for a following classification
% (data classes will be defined in data.group column)
%
% data = classification_data_settings(dataPath, analysis_types, data_type)
%
% Input:
%   dataPath is the main folder of the study
%   analysis_types is the cell array which contains the measures and the
%       spatial subdivisions which have to be considered (each measure is
%       followed by a cell array containing the spatial subdivisions, for
%       example {'PLI', {'Channels', 'Global'}, 'PSDr', {'Asymmetry'}})
%   data_type is the type of data to include, between statistically
%       significant with respect to the u-test (using 'Significant'), or
%       all the features ('All')
%
% Output:
%   data is the resulting data table


function data = dataset_creation(dataPath, analysis_types, ...
    data_type)
    if nargin < 3
        data_type = 'All';
    end

    subjects = load_data(strcat(dataPath, 'Subjects.mat'));

    cat_subjects = categorical(subjects(:, end));
    sub_types = categories(cat_subjects);
    nPAT = sum(cat_subjects == sub_types{2});
    nHC = length(cat_subjects)-nPAT;
    
    outPath = path_check(create_directory(dataPath, 'Classification'));
    create_data = @significant_data;
    if strcmpi(data_type, 'All')
        create_data = @all_data;
    end
    
    cases = define_cases(dataPath, 0);
    data = [ones(nPAT, 1); zeros(nHC, 1)];
    features = {'group'};
    
    n_analysis = 0;
    n_measures = length(analysis_types)/2;
    for i = 1:n_measures
        n_analysis = n_analysis + length(analysis_types{i*2});
    end
    types = cell(1, n_analysis);
    count = 1;
    for i = 1:n_measures
        aux_measure = analysis_types{1+(i-1)*2};
        aux_analysis_types = analysis_types{i*2};
        for j = 1:length(aux_analysis_types)
            types{1, count} = char_check(strcat(aux_measure, '_', ...
                aux_analysis_types{j}));
            count = count+1;
        end
    end
    
    [data, features] = create_data(types, dataPath, features, data);
    features = check_features(features);
    data = array2table(data, 'VariableNames', features);
    save(fullfile_check(strcat(outPath, 'Classification_Data.mat')), ...
        'data')
end


function [data, features] = all_data(types, dataPath, features, ...
    data)
    dataPath = path_check(dataPath);
    for i = 1:length(types)
        measure = split(types{i}, '_');
        area = measure{2};
        measure = measure{1};
        auxPath = measurePath(dataPath, measure, area);
        bands = define_bands(auxPath, 1);
        if strcmpi(measure, 'Offset') || strcmpi(measure, 'Exponent')
            aux_band = split(bands(1), '-');
            aux_band = aux_band{1};
            aux_band2 = split(bands(end), '-');
            bands = string(strcat(aux_band, '-', aux_band2{2}));
        end
        load(fullfile_check(strcat(path_check(auxPath), 'Second.mat')));
        load(fullfile_check(strcat(path_check(auxPath), 'First.mat')));
        for loc = 1:length(Second.locations)
            for band = 1:length(bands)
                feat = strcat(measure, '_', area, '_', ...
                    Second.locations(loc), '_', bands(band));
                aux_feat = split(feat, '-');
                feat = '';
                for s =1:length(aux_feat)
                    feat = strcat(feat, aux_feat{s}, '_');
                end
                aux_feat = split(feat, " ");
                feat = '';
                for s =1:length(aux_feat)
                    feat = strcat(feat, aux_feat{s}, '_');
                end
                features = [features, feat(1:end-2)];
                aux_data = [Second.data(:, band, loc); ...
                    First.data(:, band, loc)];
                data = [data, aux_data];
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