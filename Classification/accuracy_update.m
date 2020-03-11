%% accuracy_update
% This function update accuracy, minimum accuracy and maximum accuracy
% values (the accuracy is the sum of the accuracies of the previous and the
% current classification cycles)
%
% [accuracy, min_accuracy, max_accuracy] = accuracy_update(...
%       predictions, real_classes, accuracy, max_accuracy, min_accuracy)
%
% input:
%   predictions is the array of predicted classes labels
%   real_classes is the array of the real classes labels
%   accuracy is the accuracy value which has to be updated
%   max_accuracy is the maximum accuracy value which has to be updated
%   min_accuracy is the minimum accuracy value which has to be updated
%
% output:
%   accuracy is the updated accuracy value
%   min_accuracy is the updated minimum accuracy value
%   max_accuracy is the updated maximum accuracy value


function [accuracy, min_accuracy, max_accuracy] = accuracy_update(...
    predictions, real_classes, accuracy, max_accuracy, min_accuracy)
    aux_accuracy = sum(real_classes == predictions)/length(predictions);
    accuracy = accuracy + aux_accuracy;
    if aux_accuracy > max_accuracy
        max_accuracy = aux_accuracy;
    end
    if aux_accuracy < min_accuracy
        min_accuracy = aux_accuracy;
    end
end
