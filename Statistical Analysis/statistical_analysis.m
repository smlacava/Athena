%% statistical_analysis
% This function computes the statistical analysis between two groups of
% subjects and saves data relative to significant comparisons
%
% [P, Psig, data, data_sig, STATs] = statistical_analysis(First, ...
%     Second, locs, cons, dataPath, measure, analysis, group_types, ...
%     save_check, averaged, test)
%
% input:
%   First is the data matrix relative to the first group of subjects 
%       (such as healthy controls), or the name of the file (with its path)
%       which contains it (in this case, if locs is an empty array, it will 
%       be tried to load it by this file)
%   Second is the data matrix relative to the second group of subjects
%       (such as patients), or the name of the file (with its path) which
%       contains it
%   locs is the ordered list of locations, or the name of the file which
%       contains it (with its path), or an empty array if the locations
%       list has to be loaded by the First file
%   cons is the conservativiteness value (0 for minimum conservativeness, 1
%       for maximum conservativeness)
%   dataPath is the Path relative to the main study's folder (or directory)
%   measure is the name of the analyzed measure
%   analysis is the name of the location-related analysis to compute
%       (Areas, Global, Total or Asymmetry)
%   group_types is the cell array which contains the name of the analyzed
%       groups of subjects
%   save_check has to be 1 if the user want to save also the resulting 
%       tables (0 by default)
%   averaged has to be 1 if the data matrices are related to epochs
%       averaged data, 0 otherwise (0 by default)
%   test is the name of the test, among 'utest' and 'ttest' ('utest' by
%       default)
%
% output:
%   P is the matrix of p-values for each comparison
%   Psig is the matrix containing information about the significant
%       comparisons
%   data is the matrix which contains the 2D matrix of the values
%       (exportable for external analysis)
%   data_sig is the matrix of values statistically compared and resulted as
%       significant
%   STATs is the test statistic (a single value for each test in the t-test
%       case, two elements on the same row in the u-test case)

function [P, Psig, data, data_sig, STATs] = statistical_analysis(First, ...
    Second, locs, cons, dataPath, measure, analysis, group_types, ...
    save_check, averaged, test)
    if nargin <= 7
        group_types = {'Group 0', 'Group 1'};
    end
    if nargin <= 8
        save_check = 0;
    end
    if nargin <= 9
        averaged = 0;
    end
    if nargin <= 10
        test = 'utest';
    end
    
    
    [First, Second, locs] = check_data(First, Second, locs);
    
    nFirst = size(First, 1);
    nSecond = size(Second, 1);
    nLocs = length(locs);
    nBands = 1;
    if nLocs*nFirst < numel(First)
        nBands = size(First, 2);
    end
    alpha = alpha_levelling(cons, nLocs, nBands);
    
    if strcmpi(string(test), "utest")
    	test_handle = @u_test;
        if nBands > 1
            STATs = zeros(1, 1, 2);
        else
            STATs = zeros(1, 2);
        end
    else
    	test_handle = @t_test;
        STATs = zeros(1, 1);
    end
    
    P = zeros(nBands, nLocs);
    Psig = {};
    data_sig = [];
    data = zeros(nSecond+nFirst, nBands*nLocs);
    if not(contains(dataPath, measure))
        if contains(measure, "-")
            aux_measure = split(measure, '-');
            aux_measure = aux_measure(1);
        else
            aux_measure = measure;
        end
        dataPath = strcat(path_check(dataPath), path_check(aux_measure));
    end
    bands_names = cellstr(define_bands(dataPath, nBands)');
    if not(iscell(bands_names))
        bands_names = cell(nBands, 1);
        for i = 1:nBands
            bands_names{i, 1} = char_check(strcat("Band ", string(i)));
        end
    end
    data_names = cell(1, nBands*nLocs);
    
    for i = 1:nLocs
        aux_loc = locs{i};
        if nBands > 1
            for j = 1:nBands
                index = j+nBands*(i-1);
                data_names{index} = char_check(strcat(aux_loc, ...
                    " - ", bands_names{j}));
                if averaged == 1
                    first_data = First(:, j, i);
                    second_data = Second(:, j, i);
                else
                    first_data = First(:, j, :, i);
                    second_data = Second(:, j, :, i);
                end
                [P(j, i), aux_Psig, aux_data, STAT] = ...
                    test_handle(first_data(:), ...
                    second_data(:), char_check(strcat(locs{i}, " - ", ...
                    bands_names{j})), group_types{1}, ...
                    group_types{2}, alpha);
                STATs(j, i, :) = STAT;
                data(1:nSecond, index) = Second(:, j, i);
                data(nSecond+1:end, index) = First(:, j, i);
                Psig = [Psig; aux_Psig];
                data_sig = [data_sig, aux_data];
            end
        else
                if averaged == 0
                    first_data = First(:, :, :, i);
                    second_data = Second(:, :, :, i);
                else
                    first_data = First(:, :, i);
                    second_data = Second(:, :, i);
                end
            [P(i), aux_Psig, aux_data, STAT] = ...
                test_handle(first_data(:), second_data(:), ...
                char_check(locs{i}), group_types{1}, group_types{2}, ...
                alpha);
            STATs(i, :) = STAT;
            data(1:nSecond, i) = Second(:, i);
            data(nSecond+1:end, i) = First(:, i);
            Psig = [Psig, aux_Psig];
            data_sig = [data_sig, aux_data];
        end
    end
    
    [statanType, statanDir] = save_data(dataPath, measure, analysis, ...
        locs, bands_names, data, Psig, data_sig);
    
    show_figures(data, data_names, P, bands_names, locs, Psig, ...
        statanType, statanDir, save_check, dataPath)
end


%% compute_feature_names
% This function computes the features names related to the p-value table.

function feature_names = compute_feature_names(locs, bands_names)
    nLocs = length(locs);
    nBands = length(bands_names);
    feature_names = cell(nLocs*nBands, 1);
    for i = 1:nLocs
        for j = 1:nBands
            feature_names{(i-1)*nBands+j, 1} = ...
                char_check(strcat(locs{i}, " ", bands_names{j}));
        end
    end
end


%% save_data
% This function is used to save the results related to the statistical
% analysis.

function [statanType, statanDir] = save_data(dataPath, measure, ...
    analysis, locs, bands_names, data, Psig, data_sig)
    
    statanType = strcat(measure, '_', analysis, '.mat');
    if contains(measure, '-')
        aux_measure = split(measure, '-');
        aux_measure = aux_measure(1);
    else
        aux_measure = measure;
    end
    statanDir = path_check(create_directory(path_check(...
        limit_path(dataPath, aux_measure)), path_check('StatAn')));
    subDir = path_check(create_directory(statanDir, 'Data'));
    
    statAnResult = struct();
    statAnResult.Psig = Psig;
    statAnResult.dataSig = data_sig;
    save(char_check(strcat(statanDir, statanType)), 'statAnResult')
    
    statAnData = struct();
    statAnData.feature_names = compute_feature_names(locs, bands_names);
    statAnData.data = data;
    save(char_check(strcat(subDir, statanType)), 'statAnData')
end


%% show_figures
% This function shows tables and figures related to the statistical
% analysis executed.

function show_figures(data, data_names, P, bands_names, locs, Psig, ...
    statanType, statanDir, save_check, dataPath)
    bg_color = [1 1 1];
    sig = (size(Psig, 1) ~= 0 && not(logical(sum(sum(strcmp(Psig, ''))))));
    if save_check == 1
        data_table = array2table(data);
        data_table.Properties.VariableNames = replace(replace(...
            data_names, '-', ''), ' ', '');
        p_table = array2table(P);
        p_table.Properties.VariableNames = replace(replace(locs, '-', ...
            ''), ' ', '');
        p_table.Properties.RowNames = replace(replace(bands_names, '-', ...
            ''), ' ', '');
        save(char_check(strcat(statanDir, 'Data', filesep, ...
            strtok(statanType, '.'), '_pvalues.mat')), 'p_table' )
        save(char_check(strcat(statanDir, 'Data', filesep, ...
            strtok(statanType, '.'), '_data.mat')), 'data_table' )
        if sig
            save(char_check(strcat(statanDir, 'Data', filesep, ...
                strtok(statanType, '.'), '_Psig.mat')), 'Psig' )
        end
    end
    fs1 = figure('Name', 'Data', 'NumberTitle', 'off', 'Color', bg_color);
    d = uitable(fs1, 'Data', data, 'Position', [20 20 525 375], ...
        'ColumnName', data_names);
    fs2 = figure('Name', 'Statistical Analysis - p-value', ...
        'NumberTitle', 'off', 'Color', bg_color);
    p = uitable(fs2, 'Data', P, 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);
    if sig
        if size(Psig, 1) < size(Psig, 2)
            Psig = Psig';
        end
        fs3 = figure('Color', bg_color, 'NumberTitle', 'off', ...
            'Name', 'Statistical Analysis - Significant Results');
        ps = uitable(fs3, 'Data', cellstr(Psig), 'Position', ...
            [20 20 2000, 400], 'ColumnName', {'Significant comparisons'});
    end
    if not(isempty(locs)) && not(isempty(Psig))
        sd = spatial_subdivision(locs);
        if strcmpi(sd, "Total")
            shows_significant_locations(dataPath, Psig);
        elseif strcmpi(sd, "Areas")
            shows_significant_areas(dataPath, Psig);
        end
    end
end


%% check_data
% This function check if some arguments are matrices or the name of the
% files which contain them, and eventually load them.
%
% [First, Second, locs] = check_data(First, Second, locs)
%
% Input:
%   First is the data matrix relative to the first group of subjects 
%       (such as healthy controls), or the name of the file (with its path)
%       which contains it (in this case, if locs is an empty array, it will 
%       be tried to load it by this file)
%   Second is the data matrix relative to the second group of subjects
%       (such as patients), or the name of the file (with its path) which
%       contains it
%   locs is the ordered list of locations, or the name of the file which
%       contains it (with its path), or an empty array if the locations
%       list has to be loaded by the First file
%
% Output:
%   First is the data matrix relative to the first group of subjects 
%   Second is the data matrix relative to the second group of subjects
%   locs is the ordered list of locations

function [First, Second, locs] = check_data(First, Second, locs)
    if ischar(First) || isstring(First)
        if isempty(locs)
            [First, ~, locs] = load_data(First);
        else
            First = load_data(First);
            if ischar(locs) || isStringScalar(locs)
                try
                    locs = load(locs);
                catch
                end
            end
        end
    end
    if ischar(Second) || isstring(Second)
        Second = load_data(Second);
    end
end


%% shows_significant_locations
% This function shows the locations related to the significant comparisons.

function shows_significant_locations(dataPath, Psig)
    [dataPath, measure] = split_measurePath(dataPath);
    chanlocs_file = strcat(path_check(dataPath), 'Channel_locations.mat');
    if not(exist(chanlocs_file, 'file'))
        return;
    end
    load(chanlocs_file)
    aux_struct = struct();
    aux_struct.chanlocs = chanlocs;
    channels = [];
    bands = [];
    L = length(Psig);
    nLocs = length(chanlocs);
    for i = 1:L
        aux_res = split(Psig(i));
        channels = [channels, string(aux_res(1))];
        bands = [bands, string(aux_res(3))];
    end
    band_labels = categories(categorical(bands));
    for i = 1:length(band_labels)
        idx = zeros(length(chanlocs), 1);
        channels_list = [];
        for j = 1:L
            if strcmpi(bands(j), band_labels{i})
                channels_list = [channels_list, string(channels(j))];
            end
        end
        for j = 1:length(channels_list)
            for k = 1:nLocs
                if strcmpi(channels_list(j), chanlocs(k).labels) == 1
                    idx(k) = 1;
                    break;
                end
            end
        end
        show_locations(aux_struct, {chanlocs(:).labels}, idx, ...
            strcat(measure, " ", band_labels{i}, " Hz"));
    end
end


%% shows_significant areas
% This function shows the areas related to the significant comparisons.

function shows_significant_areas(dataPath, Psig)
    [~, measure] = split_measurePath(dataPath);
    areas = [];
    bands = [];
    L = length(Psig);
    for i = 1:L
        aux_res = split(Psig(i));
        areas = [areas, string(aux_res(1))];
        bands = [bands, string(aux_res(3))];
    end
    band_labels = categories(categorical(bands));
    for i = 1:length(band_labels)
        areas_list = [];
        for j = 1:L
            if strcmpi(bands(j), band_labels{i})
                areas_list = [areas_list, string(areas(j))];
            end
        end
        show_areas(areas_list, strcat(measure, " ", band_labels{i}, " Hz"));
    end
end