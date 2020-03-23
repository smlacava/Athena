%% rf_train_test_split
% This function is used to compute the random forest classification by
% using the training-test split evaluation method
%
% [scores, labels, accuracy, min_accuracy, max_accuracy, cm, n_PAT, ...
%     n_HC] = rf_train_test_split(data, bagging_value, n_trees, scores, labels, ...
%     r, params_dim, accuracy, max_accuracy, min_accuracy, cm, n_PAT, ...
%     n_HC, testing_fraction, min_samples)
%
% input:
%   data is the data set
%   bagging_value is the bagging fraction
%   t is the learner model
%   n_trees is the number of trees
%   scores is the scores array which has to be updated
%   labels is the labels array which has to be updated
%   repetition is the repetition number
%   params_dim is the parameters dimension used by scores and labels
%   accuracy is the accuracy value which has to be updated
%   max_accuracy is the maximum accuracy value which has to be updated
%   min_accuracy is the minimum accuracy value which has to be updated
%   cm is the confusion matrix which has to be updated
%   n_PAT is the number of patient (group of subjects identified by the
%       class label 1) which has to be updated
%   n_HC is the number of healthy controls (group of subjects identified by
%       the class label 0) which has to be updated
%   testing_fraction is the fraction of samples used as testing set
%   min_samples is the minimum number of samples per class which have to be
%       present in the training set
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


function [scores, labels, accuracy, min_accuracy, max_accuracy, cm, ...
    n_PAT, n_HC] = rf_train_test_split(data, bagging_value, t, n_trees, ...
    scores, labels, repetition, params_dim, accuracy, max_accuracy, ...
    min_accuracy, cm, n_PAT, n_HC, testing_fraction, min_samples)

    [dataTrain, dataTest] = split_data(data, testing_fraction, ...
        min_samples);
    mdl = fitcensemble(dataTrain, 'group', 'Method', 'Bag', ...
        'Learners', t, 'FResample', bagging_value, ...
        'NumLearningCycles', n_trees);
    [predictions, scrs] = predict(mdl, dataTest);
    [scores, labels] = roc_update(scores, labels, scrs, ...
        dataTest.group, repetition, params_dim);  
    [accuracy, min_accuracy, max_accuracy] = accuracy_update(...
        predictions, dataTest.group, accuracy, max_accuracy, ...
        min_accuracy);
    [cm, n_PAT, n_HC] = confusion_matrix_update(predictions, ...
        dataTest.group, cm, n_PAT, n_HC);
end