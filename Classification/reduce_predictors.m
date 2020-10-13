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
        bg_color = [1 1 1];
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
    labels = data{:, 1};
    
    [~, scrs, ~, ~, pctExp] = pca(raw_data);
    
    features = {};
    for i = 1:length(pctExp)
        features = [features, char(strcat("PC", string(i)))];
        if sum(pctExp(1:i)) >= pca_value
            data = scrs(:, 1:i);
            break
        end
    end
    if pca_value == 100
        data = scrs(:, 1:end);
    end
    
    pc = figure('Color', bg_color, 'NumberTitle', 'off', 'Name', ...
        'Principal Component Analysis');
    hold on
    pareto(pctExp)
    xlim([0 n_predictors+1])
    xticklabels(features)
    xticks(1:length(features))
    xtickangle(45)
    plot([n_predictors n_predictors+1], [100 100], 'Color', ...
        [0.00, 0.45, 0.74]);
    real_value = sum(pctExp(1:i));
    plot([i i], [-1 101], '--r')
    plot(i, real_value, 'ro')
    hold off
    
    data = [labels, data];
    data = array2table(data, 'VariableNames', ['group', features]);
end