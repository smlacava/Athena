%% index correlation
% This function computes the correlation between a measure matrix and an
% index array relative to each analyzed subject.
% 
% index_correlation(data, sub_list, bands_names, measure, Index, alpha, ...
%       bg_color, locs, P, RHO, nLoc, nBands)    
%
% input:
%   data is the data matrix to correlate
%   sub_list is the cell array which contains the subjects' names of the
%       considered group
%   bands_names is the cell array which containd the names of each
%       frequency band
%   measure is the name of the considered measure
%   Index is the array which contains the index for each subject, in order
%   alpha is the alpha level value
%   bg_color is the rgb code of the background color
%   locs is the cell array which contains the name of each location, in
%       order
%   P is the p-value matrix which has to be computed
%   RHO is the rho matrix which has to be computed
%   nLoc is the number of considered locations
%   nBands is the number of considered frequency bands


function index_correlation(data, sub_list, bands_names, measure, Index, ...
    alpha, bg_color, locs, P, RHO, nLoc, nBands)    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Correlations');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    for i = 1:nLoc
        if nBands > 1
            for j = 1:nBands
                [P(i, j), RHO(i, j)] = correlation(data(:, j, i), ...
                    Index(:, end), char_check(strcat("Band ", ...
                    string(j), " ", locs{i})), measure, 'Index', ...
                    sub_list, alpha);
            end
        else
            [P(i, 1), RHO(i, 1)] = correlation(data(:, i), ...
                Index(:, end), char_check(locs{i}), measure, 'Index', ...
                sub_list, alpha);
        end
    end
    fs1 = figure('Name', char_check(strcat("Index Correlation - ", ...
        "p-value (alpha level ", string(alpha), ")")), ...
        'NumberTitle', 'off', 'Color', bg_color);
    p = uitable(fs1, 'Data', P', 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);
    fs2 = figure('Name', char_check(strcat("Index Correlation - ", ...
        "rho (alpha level ", string(alpha), ")")), ...
        'NumberTitle', 'off', 'Color', bg_color);
    r = uitable(fs2, 'Data', RHO', 'Position', [20 20 525 375], ...
        'RowName', bands_names, 'ColumnName', locs);