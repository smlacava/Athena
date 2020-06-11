%% index correlation
% This function computes the correlation between the matrices of two
% measures.
% 
% measures_correlation(xData, yData, sub_list, bands_names, measures, ...
%       alpha, bg_color, locs, P, RHO, nLoc, nBands, save_check, dataPath)   
%
% input:
%   xData is the first data matrix to correlate
%   yData is the second data matrix to correlate
%   sub_list is the cell array which contains the subjects' names of the
%       considered group
%   bands_names is the cell array which containd the names of each
%       frequency band
%   measures is the cell array which contains the names of the first and
%       the second measure to correlate, in order
%   alpha is the alpha level value
%   bg_color is the rgb code of the background color
%   locs is the cell array which contains the name of each location, in
%       order
%   P is the p-value matrix which has to be computed
%   RHO is the rho matrix which has to be computed
%   nLoc is the number of considered locations
%   nBands is the number of considered frequency bands
%   save_check has to be 1 if the user wants to save the resulting graphs
%       (0 by default)
%   dataPath is the directory where to save the data (optional)


function measures_correlation(xData, yData, sub_list, bands_names, ...
    measures, alpha, bg_color, locs, P, RHO, nLoc, nBands, save_check, ...
    dataPath)    
    if nargin < 13
        dataPath = '';
    end
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Correlations');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    if isempty(P)
        P = zeros(nLoc, nBands);
    end
    if isempty(RHO)
        RHO = zeros(nLoc, nBands);
    end
    if ischar(sub_list)
        sub_list = load_data(sub_list);
    end
    if ischar(locs)
        locs = load_data(locs);
    end
    
    for i = 1:nLoc
        if nBands > 1
            for j = 1:nBands
                [P(i, j), RHO(i, j)] = correlation(xData(:, j, i), ...
                    yData(:, j, i), char_check(strcat("Band ", ...
                    string(j), " ", locs{i})), measures(1), ...
                    measures(2), sub_list, alpha);
            end
        else
            [P(i, 1), RHO(i, 1)] = correlation(xData(:, i), ...
                yData(:, i), char_check(locs{i}), measures(1), ...
                measures(2), sub_list, alpha);
        end
    end
    
    if save_check == 1
        aux_locs = locs;
        if sum(contains(locs, {'Frontal', 'Parietal', 'Occipital', ...
                'Central', 'Temporal'})) > 1
            locs = 'Areas';
        elseif not(contains(locs, 'Asymmetry')) && ...
                not(contains(locs, 'Global'))
            locs = total;
        end
        save_name = strcat(dataPath, filesep, 'correlation_', ...
            measures{1}, '_', measures{2}, '_', locs);
        p_table = array2table(P');
        rho_table = array2table(RHO');
        try
            p_table.Properties.VariableNames = replace(replace(aux_locs, '-', ...
                ''), ' ', '');
            rho_table.Properties.VariableNames = replace(replace(aux_locs, '-', ...
                ''), ' ', '');
        catch
            if contains(char(locs), 'global')
                locs = 'globality';
            end
            p_table.Properties.VariableNames = {char(replace(replace(locs, '-', ...
                ''), ' ', ''))};
            rho_table.Properties.VariableNames = {char(replace(replace(locs, '-', ...
                ''), ' ', ''))};
        end
        try
            p_table.Properties.RowNames = replace(replace(bands_names, '-', ...
                ''), ' ', '');
            rho_table.Properties.RowNames = replace(replace(bands_names, '-', ...
                ''), ' ', '');
        catch
            p_table.Properties.RowNames = {char(replace(replace(bands_names, '-', ...
                ''), ' ', ''))};
            rho_table.Properties.RowNames = {char(replace(replace(bands_names, '-', ...
                ''), ' ', ''))};
        end
        save(strcat(save_name, '_pvalues.mat'), 'p_table' )
        save(strcat(save_name, '_rho.mat'), 'rho_table' )
        locs = aux_locs;
    end
    fs1 = figure('Name', char_check(strcat("Measures Correlation - ", ...
        "p-value (alpha level ", string(alpha), ")")), ...
        'NumberTitle', 'off', 'Color', bg_color);
    p = uitable(fs1, 'Data', P', 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);
    fs2 = figure('Name', char_check(strcat("Measures Correlation - ", ...
        "rho (alpha level ", string(alpha), ")")), ...
        'NumberTitle', 'off', 'Color', bg_color);
    r = uitable(fs2, 'Data', RHO', 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);