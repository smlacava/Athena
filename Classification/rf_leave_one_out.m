%% rf_leave_one_out
% This function is used to compute the random forest classification by
% using the leave one out cross validation method
%
% [scores, labels, accuracy, min_accuracy, max_accuracy, cm, n_PAT, ...
%     n_HC] = rf_holdout(data, bagging_value, n_trees, scores, labels, ...
%     r, params_dim, accuracy, max_accuracy, min_accuracy, cm, n_PAT, n_HC)
%
% input:
%   data is the data set
%   bagging_value is the bagging fraction
%   t is the learner model
%   n_trees is the number of trees
%   scores is the scores array which has to be updated
%   labels is the labels array which has to be updated
%   r is the repetition number
%   params_dim is the parameters dimension used by scores and labels
%   accuracy is the accuracy value which has to be updated
%   max_accuracy is the maximum accuracy value which has to be updated
%   min_accuracy is the minimum accuracy value which has to be updated
%   cm is the confusion matrix which has to be updated
%   n_PAT is the number of patient (group of subjects identified by the
%       class label 1) which has to be updated
%   n_HC is the number of healthy controls (group of subjects identified by
%       the class label 0) which has to be updated
%   rejected is the list of rejected samples
%   reject_value is the percentage is the minimum probability of 
%       classification relative to the assigned class, under which the 
%       sample is rejected
%
% output:
%   scores is the updated scores array
%   labels is the updated labels array
%   accuracy is the updated accuracy value
%   min_accuracy is the updated minimum accuracy value
%   max_accuracy is the updated maximum accuracy value
%   cm is the updated confusion matrix
%   n_PAT is the updated number of patients
%   n_HC is the updated number of healthy controls
%   rejected is the updated list of rejected samples


function [scores, labels, accuracy, min_accuracy, max_accuracy, cm, ...
    n_PAT, n_HC, rejected] = ...
    rf_leave_one_out(data, bagging_value, t, n_trees, scores, labels, ...
    r, params_dim, accuracy, max_accuracy, min_accuracy, cm, n_PAT, ...
    n_HC, testing_fraction, min_samples, rejected, reject_value)
    
    nonrejected = [];
    aux_accuracy = 0;
    if r == 1
        scores = [];
        labels = [];
    end
    for i = 1:size(data.group, 1)
        dataTrain = data;
        dataTrain(i, :) = [];
        dataTest = data(i, :);
        mdl = fitcensemble(dataTrain, 'group', 'Method', 'Bag', ...
            'Learners', t, 'FResample', bagging_value, ...
            'NumLearningCycles', n_trees);
        [predictions, scrs] = predict(mdl, dataTest);
        if scrs(end) < reject_value && scrs(end) > 1-reject_value
            rejected = [rejected; dataTest.group];
            continue
        end
        nonrejected = [nonrejected; dataTest.group];
        labels = [labels; dataTest.group];
        scores = [scores; scrs(end)];
        [cm, n_PAT, n_HC] = confusion_matrix_update(predictions, ...
            dataTest.group, cm, n_PAT, n_HC);
        aux_accuracy = aux_accuracy+(predictions == dataTest.group);
    end
    aux_accuracy = aux_accuracy/length(nonrejected);
    accuracy = accuracy+aux_accuracy;
    if aux_accuracy < min_accuracy
        min_accuracy = aux_accuracy;
    elseif aux_accuracy > max_accuracy
        max_accuracy = aux_accuracy;
    end
end