%% performance
% This function computes the average performance of the classifier
%
% [cm, AUC, roc, conf_mat, accuracy] = ...
%        performance(repetitions, cm, n_PAT, n_HC, labels, scores, ...
%        accuracy, bg_color)
%
% input:
%   cm is the confusion matrix
%   repetitions is the number of repetitions
%   n_PAT is the number of patients (group 1)
%   n_HC is the number of healthy controls (group 0)
%   labels is the array which contains the testing samples' class labels
%   scores is the array which contains the scores of each sample
%   accuracy is the accuracy value
%   bg_color is the background color
%
% output:
%   cm is the updated confusion matrix
%   AUC is the AUC (Area Under the Curve) value
%   roc is the figure which shows the ROC (Receiver Operating
%       Characteristics) curve
%   conf_mat is the figure which shows the confusion matrix
%   accuracy is the updated accuracy value


function [cm, AUC, roc, conf_mat, accuracy] = ...
    performance(repetitions, cm, n_PAT, n_HC, labels, scores, ...
    accuracy, bg_color)
    
    accuracy = accuracy/repetitions;
    cm(1, :) = cm(1, :)/n_PAT;
    cm(2, :) = cm(2, :)/n_HC;
    [AUC, roc] = ROC_curve(labels, scores, bg_color);
    conf_mat = confusion_matrix(cm, accuracy, bg_color);
end