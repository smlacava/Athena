%% index correlation
% This function computes the correlation between a measure matrix and an
% index array relative to each analyzed subject.
% 
% index_correlation(data, sub_list, bands_names, measure, Index, alpha, ...
%       bg_color, locs, P, RHO, nLoc, nBands, save_check, dataPath, ...
%       save_check_fig, format)    
%
% input:
%   data is the data matrix to correlate
%   sub_list is the cell array which contains the subjects' names of the
%       considered group
%   bands_names is the cell array which containd the names of each
%       frequency band
%   measure is the name of the considered measure
%   Index is the array which contains the index for each subject, in order
%       (or the name of the file which contains it)
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
%   save_check_fig is 1 if the resulting figures have to be saved (0 
%       otherwise)
%   format is the format in which the figures have to be eventually saved


function index_correlation(data, sub_list, bands_names, measure, Index, ...
    alpha, bg_color, locs, P, RHO, nLoc, nBands, save_check, dataPath, ...
    save_check_fig, format)    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Correlations');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    if nargin < 13
        save_check = 0;
    end
    if nargin < 14
        dataPath = '';
    end
    if nargin < 15
        save_check_fig = 0;
    end
    if nargin < 16
        format = '';
    end
    if isempty(P)
        P = zeros(nLoc, nBands);
    end
    if isempty(RHO)
        RHO = zeros(nLoc, nBands);
    end
    if ischar(Index)
        Index = load_data(Index);
    end
    
    for i = 1:nLoc
        if nBands > 1
            for j = 1:nBands
                [P(i, j), RHO(i, j)] = correlation(data(:, j, i), ...
                    Index(:, end), char_check(strcat(locs{i}, " ", ...
                    bands_names{j})), measure, 'Index', sub_list, ...
                    alpha, save_check_fig, format, dataPath);
            end
        else
            [P(i, 1), RHO(i, 1)] = correlation(data(:, i), ...
                Index(:, end), char_check(locs{i}), measure, 'Index', ...
                sub_list, alpha, save_check_fig, format, dataPath);
        end
    end
    
    if save_check == 1
        aux_locs = locs;
        if sum(contains(locs, {'Frontal', 'Parietal', 'Occipital', ...
                'Central', 'Temporal'})) > 1
            locs = 'Areas';
        elseif not(contains(locs, 'Asymmetry')) && ...
                not(contains(locs, 'Global'))
            locs = 'Channels';
        end
            
        save_name = strcat(dataPath, filesep, 'correlation_', ...
            measure, '_Index_', locs);
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
            p_table.Properties.RowNames = bands_names;
            rho_table.Properties.RowNames = bands_names;
        end
        save(strcat(save_name, '_pvalues.mat'), 'p_table' )
        save(strcat(save_name, '_rho.mat'), 'rho_table' )
        locs = aux_locs;
    end
    
    fs1 = figure('Name', char_check(strcat("Index Correlation - ", ...
        "p-value (alpha level ", string(alpha), ")")), ...
        'NumberTitle', 'off', 'Color', [1 1 1]);
    p = uitable(fs1, 'Data', P', 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);
    fs2 = figure('Name', char_check(strcat("Index Correlation - ", ...
        "rho (alpha level ", string(alpha), ")")), ...
        'NumberTitle', 'off', 'Color', [1 1 1]);
    r = uitable(fs2, 'Data', RHO', 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);