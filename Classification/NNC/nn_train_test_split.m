%% nn_train_test_split
% This function is used to compute the neural network classification by
% using the training-test split evaluation method
%
% [scores, labels, accuracy, min_accuracy, max_accuracy, cm, n_PAT, ...
%     n_HC] = nn_train_test_split(data, validation_value, net, scores, ...
%     labels, repetition, params_dim, accuracy, max_accuracy, ...
%     min_accuracy, cm, n_PAT, n_HC, testing_value, min_samples, ...
%     rejected, reject_value)
%
% input:
%   data is the data set
%   validation_value is the validating fraction
%   net is the learner model
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
    n_PAT, n_HC, rejected] = nn_train_test_split(data, ...
    validation_value, nnet, scores, labels, repetition, params_dim, ...
    accuracy, max_accuracy, min_accuracy, cm, n_PAT, n_HC, ...
    testing_value, min_samples, rejected, reject_value)
    
    features = data.Properties.VariableNames;
    all_labels = data.group';
    aux_data = data{:, 2:end}';
    clear data
    data = aux_data;
    clear aux_data
    
    [nnet, dataTest, dataTest_mat] = split_initialization(nnet, ...
        validation_value, testing_value, data, all_labels, min_samples, ...
        features);
    
    [scrs, predictions] = split_prediction(nnet, dataTest_mat);
    
    [rejected, nonrejected, scrs, predictions] = ...
        update_rejected(dataTest, rejected, reject_value, scrs, ...
        predictions);
    [scores, labels] = roc_update(scores, labels, scrs, ...
        nonrejected);
    [accuracy, min_accuracy, max_accuracy] = accuracy_update(...
        predictions, nonrejected, accuracy, max_accuracy, ...
        min_accuracy);
    [cm, n_PAT, n_HC] = confusion_matrix_update(predictions, ...
        nonrejected, cm, n_PAT, n_HC);
end


function [nnet, dataTest, dataTest_mat] = split_initialization(nnet, ...
    validation_value, testing_value, data, all_labels, min_samples, ...
    features)

    training_value = 1-validation_value-testing_value;
    nnet = init(nnet);
    nnet.trainParam.showWindow = false;
    nnet.divideParam.trainRatio = training_value;
    nnet.divideParam.valRatio = validation_value;
    nnet.divideParam.testRatio = testing_value;
    [nnet, dataTest, dataTest_mat] = check_split(nnet, data, ...
        all_labels, min_samples, features);
end


function [nnet, dataTest, dataTest_mat] = check_split(nnet, data, ...
    all_labels, min_samples, features)

    [nnet, info] = train(nnet, data, all_labels);
    labelTrain = all_labels(:, info.trainInd);
    while sum(labelTrain) < min_samples || ...
            sum(labelTrain) == length(labelTrain)
        nnet = init(nnet);
        nnet.trainParam.showWindow = false;
        [nnet, info] = train(nnet, dataset, all_labels);
        labelTrain = all_labels(:, info.trainInd);
    end 
    dataTest_mat = data(:, info.testInd);
    dataTest = array2table([all_labels(:, info.testInd)' dataTest_mat'], ...
        'VariableNames', features);
end


function [scrs, predictions] = split_prediction(nnet, dataTest_mat)
    scrs = nnet(dataTest_mat);
    scrs = [(1-scrs); scrs];
    [~, predictions] = max(scrs);
    predictions = predictions'-1;
    scrs = scrs';
end