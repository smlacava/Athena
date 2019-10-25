%% correlation
% This function computes the correlation between two measures to give in
% output a plot of the second measure over the first one and useful data
% such as the p-value and the Spearman's rho (correlation index) 
% 
% correlation(data1, data2, locList, type1, type2, sub)
%
% input:
%   data1 is the first column vector to correlate
%   data2 is the second column vector to correlate
%   loc is the name of the location analyzed (optional)
%   type1 is the first data type (optional)
%   type2 is the second data type (optional)
%   sub is the array of the names of the subjects (optional)

function []=correlation(data1, data2, loc, type1, type2, sub)
switch nargin
    case 2
        loc="Correlation";
        type1="Data 1";
        type2="Data 2";
        sub=[];
    case 3
        type1="Data 1";
        type2="Data 2";
        sub=[];
    case 4
        type2="Data 2";
        sub=[];
    case 5
        sub=[];
end

    [RHO,PVAL]=corr(data1,data2,'type','Spearman');
    figure('Name',loc,'NumberTitle','off','ToolBar','none')
    set(gcf, 'color', [0.67 0.98 0.92])
    scatter(data1,data2,'MarkerEdgeColor',[0.05 0.02 0.8])
    title(strcat('p-value=',string(PVAL),', rho=', string(RHO)))
    xlabel(type1)
    ylabel(type2)
        
    coefficients = polyfit(data1, data2, 1);
    xFit = linspace(min(data1), max(data1), 1000);
    yFit = polyval(coefficients , xFit);
    hold on;
    p=plot(xFit, yFit, 'k-', 'LineWidth', 2);
    grid on;
    if not(isempty(sub))
        gname(sub)
    end
end