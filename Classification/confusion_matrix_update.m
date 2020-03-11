%% confusion_matrix_update
% This function is used to update the confusion matrix and the number of
% patients and healthy controls (the confusion matrix is the sum of the 
% confusion matrices of the previous and the current classification cycles)
%
% [confusion_matrix, n_PAT, n_HC] = confusion_matrix_update(...
%       predictions, real_classes, confusion_matrix, n_PAT, n_HC)
%
% input:
%   predictions is the array of the predicted classes labels
%   real_classes is the array of the real classes labels
%   confusion_matrix is the confusion matrix which has to be updated 
%       ([true_PAT, false_HC; false_PAT, true_HC])
%   n_PAT is the number of patients which has to be updated
%   n_HC is the number of healthy controls which has to be updated
%   
% output:
%   confusion_matrix is the updated confusion matrix
%   n_PAT is updated number of patients
%   n_HC is the updated number of healthy controls


function [confusion_matrix, n_PAT, n_HC] = confusion_matrix_update(...
    predictions, real_classes, confusion_matrix, n_PAT, n_HC)
    n_PAT = n_PAT+sum(real_classes == 1);
    n_HC = n_HC+sum(real_classes == 0);
    
    aux_FPAT =  sum(predictions > real_classes);
    aux_TPAT = sum((predictions == real_classes) & (predictions == 1));
    aux_FHC = sum(predictions < real_classes);
    aux_THC = sum((predictions == real_classes) & (predictions == 0));
    
    % confusion matrix: [true_PAT, false_HC; false_PAT, true_HC]
    confusion_matrix(1, 1) = confusion_matrix(1, 1)+aux_TPAT;
    confusion_matrix(1, 2) = confusion_matrix(1, 2)+aux_FHC;
    confusion_matrix(2, 1) = confusion_matrix(2, 1)+aux_FPAT;
    confusion_matrix(2, 2) = confusion_matrix(2, 2)+aux_THC;
end