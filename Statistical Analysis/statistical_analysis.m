%% statistical_analysis
% This function computes the statistical analysis between two groups of
% subjects and saves data relative to significant comparisons
%
% [P, Psig, data, data_sig] = statistical_analysis(HC, PAT, locs, cons, ...
%     dataPath, measure, analysis)
%
% input:
%   HC is the data matrix relative to the first group of subjects (healty
%       controls)
%   PAT is the data matrix relative to the second group of subjects
%       (patients)
%   locs is the ordered list of locations
%   cons is the conservativiteness value (0 for minimum conservativeness, 1
%       for maximum conservativeness)
%   dataPath is the path relative to the main study's folder (or directory)
%   measure is the name of the analyzed measure
%   analysis is the name of the location-related analysis to compute
%       (Areas, Global, Total or Asymmetry)
%
% output:
%   P is the matrix of p-values for each comparison
%   Psig is the matrix containing information about the significant
%       comparisons
%   data is the matrix which contains the 2D matrix of the values
%       (exportable for external analysis)
%   data_sig is the matrix of values statistically compared and resulted as
%       significant

function [P, Psig, data, data_sig] = statistical_analysis(HC, PAT, ...
    locs, cons, dataPath, measure, analysis)
    
    nHC = size(HC, 1);
    nPAT = size(PAT, 1);
    nLocs = length(locs);
    nBands = 1;
    if nLocs*nHC < numel(HC)
        nBands = size(HC, 2);
    end
    alpha = alpha_levelling(cons, nLocs, nBands);
    P = zeros(nBands, nLocs);
    Psig = {};
    data_sig = [];
    data = zeros(nPAT+nHC, nBands*nLocs);
    bands_names = cell(nBands, 1);
    for i = 1:nBands
        bands_names{i, 1} = char_check(strcat("Band ", string(i)));
    end
    data_names = cell(1, nBands*nLocs);
    
    for i = 1:nLocs
        aux_loc = locs{i};
        if nBands > 1
            for j = 1:nBands
                index = j+nBands*(i-1);
                data_names{index} = char_check(strcat(aux_loc, ...
                    " - Band ", string(j)));
                [P(j, i), aux_Psig, aux_data] = t_test(PAT(:, j, i), ...
                    HC(:, j, i), char_check(strcat("Band ", string(j), ...
                    " ", locs{i})), 'PAT', 'HC', alpha);
                data(1:nPAT, index) = PAT(:, j, i);
                data(nPAT+1:end, index) = HC(:, j, i);
                Psig = [Psig; aux_Psig];
                data_sig = [data_sig, aux_data];
            end
        else
            [P(i), aux_Psig, aux_data] = t_test(PAT(:, i), HC(:, i), ...
                char_check(locs{i}), 'PAT', 'HC', alpha);
            data(1:nPAT, i) = PAT(:, i);
            data(nPAT+1:end, i) = HC(:, i);
            Psig = [Psig, aux_Psig];
            data_sig = [data_sig, aux_data];
        end
    end
    
    show_figures(data, data_names, P, bands_names, locs, Psig)
    
    save_data(dataPath, measure, analysis, locs, nBands, data, Psig, ...
        data_sig)
end


function feature_names = compute_feature_names(locs, nBands)
    nLocs = length(locs);
    feature_names = cell(nLocs*nBands, 1);
    for i = 1:nLocs
        for j = 1:nBands
            feature_names{(i-1)*nBands+j, 1} = ...
                char_check(strcat("Band ", string(j), " ", locs{i}));
        end
    end
end


function save_data(dataPath, measure, analysis, locs, nBands, data, ...
    Psig, data_sig)

    statanType = strcat(measure, '_', analysis, '.mat');
    statanDir = path_check(create_directory(path_check(...
        limit_path(dataPath, measure)), path_check('StatAn')));
    subDir = path_check(create_directory(statanDir, 'Data'));
    
    statAnResult = struct();
    statAnResult.Psig = Psig;
    statAnResult.dataSig = data_sig;
    save(char_check(strcat(statanDir, statanType)), 'statAnResult')
    
    statAnData = struct();
    statAnData.feature_names = compute_feature_names(locs, nBands);
    statAnData.data = data;
    save(char_check(strcat(subDir, statanType)), 'statAnData')
end


function show_figures(data, data_names, P, bands_names, locs, Psig)
    bg_color = [0.67 0.98 0.92];
    fs1 = figure('Name', 'Data', 'NumberTitle', 'off', 'Color', bg_color);
    d = uitable(fs1, 'Data', data, 'Position', [20 20 525 375], ...
        'ColumnName', data_names);
    fs2 = figure('Name', 'Statistical Analysis - p-value', ...
        'NumberTitle', 'off', 'Color', bg_color);
    p = uitable(fs2, 'Data', P, 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);
        
    if size(Psig, 1) ~= 0 && not(logical(sum(sum(strcmp(Psig, '')))))
        fs3 = figure('Color', bg_color, 'NumberTitle', 'off', ...
            'Name', 'Statistical Analysis - Significant Results');
        ps = uitable(fs3, 'Data', cellstr(Psig), 'Position', ...
            [20 20 525 375], 'ColumnName', {'Significant comparisons'});
    end
end