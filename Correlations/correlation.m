%% correlation
% This function computes the correlation between two measures to give in
% output a plot of the second measure over the first one and useful data
% such as the p-value and the Spearman's rho (correlation index) 
% 
% correlation(data1, data2, locList, type1, type2, sub, alpha)
%
% input:
%   data1 is the first column vector to correlate
%   data2 is the second column vector to correlate
%   loc is the name of the location analyzed (optional)
%   type1 is the first data type (optional)
%   type2 is the second data type (optional)
%   sub is the array of the names of the subjects (optional)
%   alpha is the alpha level
%
% output:
%   PVAL is the p-value for testing the hypotesis of no correlation against
%       the one of non-zero correlation
%   RHO is pairwise correlation coefficient between input data

function [PVAL, RHO] = correlation(data1, data2, loc, type1, type2, ...
    sub, alpha)
    switch nargin
        case 2
            loc = "Correlation";
            type1 = "Data 1";
            type2 = "Data 2";
            sub = [];
            alpha = [];
        case 3
            type1 = "Data 1";
            type2 = "Data 2";
            sub = [];
            alpha = [];
        case 4
            type2 = "Data 2";
            sub = [];
            alpha = [];
        case 5
            sub = [];
            alpha = [];
        case 6
            alpha = [];
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
    if not(isempty(sub))
        gname(sub)
    end
end