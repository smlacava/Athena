%% ROC_curve
% This function computes the ROC (Receiver Operating Characteristic) curve 
% and the AUC (Area Under the Curve) value
%
% [AUC, fig] = ROC_curve(labels, scores, bg_color)
% 
% input:
%   labels is the array which contains all the testing sets' class labels
%   scores is the array which contains all the predictions' scores
%   bg_color is the background color of the figure which will show the
%       Receiver Operating Characteristic (ROC) curve
%
% output:
%   AUC is the Area Under the Curve value
%   fig is the figure which shows the ROC curve


function [AUC, fig] = ROC_curve(labels, scores, bg_color)
    fig = figure('Color', bg_color, 'NumberTitle', 'off', ...
    	'Name', 'ROC curve');
    hold on
    
    [X, Y, ~, AUC] = perfcurve(labels, scores, 1, 'XVals', [0:0.05:1]);    
    plot(X, Y)
    title(strcat("AUC = ", string(AUC)))
    xlim([0 1])
    ylim([0 1])
    hold off
end