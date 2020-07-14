%% correlation
% This function computes the correlation between two measures to give in
% output a plot of the second measure over the first one and useful data
% such as the p-value and the Spearman's rho (correlation index) 
% 
% correlation(data1, data2, locList, type1, type2, sub, alpha, ...
%         save_check, format, dataPath)
%
% input:
%   data1 is the first column vector to correlate
%   data2 is the second column vector to correlate
%   loc is the name of the location analyzed (optional)
%   type1 is the first data type (optional)
%   type2 is the second data type (optional)
%   sub is the array of the names of the subjects (optional)
%   alpha is the alpha level
%   save_check is 1 if the resulting figures have to be saved (0 otherwise)
%   format is the format in which the figures have to be eventually saved
%
% output:
%   PVAL is the p-value for testing the hypotesis of no correlation against
%       the one of non-zero correlation
%   RHO is pairwise correlation coefficient between input data

function [PVAL, RHO] = correlation(data1, data2, loc, type1, type2, ...
    sub, alpha, save_check, format, dataPath)
    switch nargin
        case 2
            loc = "Correlation";
            type1 = "Data 1";
            type2 = "Data 2";
            sub = [];
            alpha = [];
            save_check = 0;
            format = '';
            dataPath = '';
        case 3
            type1 = "Data 1";
            type2 = "Data 2";
            sub = [];
            alpha = [];
            save_check = 0;
            format = '';
            dataPath = '';
        case 4
            type2 = "Data 2";
            sub = [];
            alpha = [];
            save_check = 0;
            format = '';
            dataPath = '';
        case 5
            sub = [];
            alpha = [];
            save_check = 0;
            format = '';
            dataPath = '';
        case 6
            alpha = [];
            save_check = 0;
            format = '';
            dataPath = '';
        case 7
            save_check = 0;
            format = '';
            dataPath = '';
        case 8
            format = '';
            dataPath = '';
        case 9
            dataPath = '';
    end

    [RHO, PVAL] = corr(data1, data2, 'type', 'Spearman');
    sig_check = ': not significant';
    if PVAL < alpha
        sig_check = ': significant';
    end
    
    figure('Name', loc, 'NumberTitle', 'off', 'ToolBar', 'none')
    set(gcf, 'color', [1 1 1])
    scatter(data1, data2, 'MarkerEdgeColor', [0.05 0.02 0.8])
    title(strcat('p-value=', char_check(PVAL), ', rho=', string(RHO), ...
        sig_check))
    xlabel(type1)
    ylabel(type2)
        
    coefficients = polyfit(data1, data2, 1);
    xFit = linspace(min(data1), max(data1), 1000);
    yFit = polyval(coefficients, xFit);
    hold on;
    p = plot(xFit, yFit, 'k-', 'LineWidth', 2);
    grid on;
    
    if save_check == 1
        outDir = create_directory(dataPath, 'Figures');
        if strcmp(format, '.fig')
            savefig(char_check(strcat(path_check(outDir), ...
                'Correlation_', type1, '_', type2, '_', loc, format)));
        else
            Image = getframe(gcf);
            imwrite(Image.cdata, char_check(strcat(...
                path_check(outDir), 'Correlation_', type1, '_', type2, ...
                '_', loc, format)));
        end
    end
    if not(isempty(sub))
        gname(sub)
    end
end