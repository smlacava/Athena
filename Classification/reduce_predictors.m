%% reduce_predictors
% This function reduces the number of predictors through the principal
% component analysis
%
% [data, pc] = reduce_predictors(data, pca_value, bg_color)
%
% input:
%   data is the data table
%   pca_value is the variance percentage threshold to reduce the number of
%       predictors through the principal component analysis
%   bg_color is the background color of the principal component analysis
%       graphic representation
%
% output:
%   data is the reduced data table
%   pc is the principal component analysis graphic representation


function [data, pc] = reduce_predictors(data, pca_value, bg_color)
    if nargin == 2
        bg_color = [0.67 0.98 0.92];
    end
    
    if isempty(pca_value) || pca_value <=0 || pca_value > 100
        pc = [];
        problem(strcat("The pca percentage has to be a value between ", ...
        "0 and 100 (the classification process will continue by ", ...
        "considering all the predictors)"))
        return
    end
    
    aux_predictors = data.Properties.VariableNames;
    n_predictors = length(aux_predictors)-1;
    predictors = cell(1, n_predictors);
    for i = 1:n_predictors
        aux = aux_predictors{i+1};
        aux = split(aux, 'major');
        predictors{i} = aux{1};
    end
    raw_data = data{:, 2:end};
    
    [~, ~, ~, ~, pctExp] = pca(raw_data);
    
    
    if pca_value < 100
        for i = 1:length(pctExp)
            if sum(pctExp(1:i)) >= pca_value
                data = data(:, 1:i+1);
                break
            end
        end
    else
        i = n_predictors;
    end
    
    pc = figure('Color', bg_color, 'NumberTitle', 'off', 'Name', ...
        'Principal Component Analysis');
    hold on
    pareto(pctExp)
    xlim([0 n_predictors])
    xticklabels(predictors)
    xticks(1:n_predictors)
    xtickangle(45)
    if pca_value < 100
        real_value = sum(pctExp(1:i));
        plot([i i], [-1 101], '--r')
        plot(i, real_value, 'ro')
    end
    hold off
end