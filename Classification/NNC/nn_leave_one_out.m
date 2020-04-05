%% nn_leave_one_out
% This function is used to compute the neural network classification by
% using the leave one out cross validation method
%
% [scores, labels, accuracy, min_accuracy, max_accuracy, cm, n_PAT, ...
%     n_HC] = nn_leave_one_out(data, validation_value, net, scores, ...
%     labels, r, params_dim, accuracy, max_accuracy, ...
%     min_accuracy, cm, n_PAT, n_HC, testing_value, min_samples, ...
%     rejected, reject_value)
%
% input:
%   data is the data set
%   validation_value is the validating fraction
%   net is the learner model
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
    n_PAT, n_HC, rejected] = nn_leave_one_out(data, ...
    validation_value, nnet, scores, labels, r, params_dim, ...
    accuracy, max_accuracy, min_accuracy, cm, n_PAT, n_HC, ...
    testing_value, min_samples, rejected, reject_value)
    
    features = data.Properties.VariableNames;
    all_labels = data.group';
    aux_data = data{:, 2:end}';
    clear data
    data = aux_data;
    clear aux_data
    
    nonrejected = [];
    aux_accuracy = 0;
    if r == 1
        scores = [];
        labels = [];
    end
    for i = 1:length(all_labels)
        [nnet, dataTest, dataTest_mat] = llo_initialization(nnet, ...
            validation_value, i, data, all_labels, min_samples, features);
    
        [scrs, predictions] = split_prediction(nnet, dataTest_mat);
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


function [nnet, dataTest, dataTest_mat] = llo_initialization(nnet, ...
    validation_value, repetition, data, all_labels, min_samples, ...
    features)
   
    training_value = 1-validation_value;
    nnet = init(nnet);
    nnet.trainParam.showWindow = false;
    nnet.divideParam.trainRatio = training_value;
    nnet.divideParam.valRatio = validation_value;
    nnet.divideParam.testRatio = 0;
    [nnet, dataTest, dataTest_mat] = check_llo(nnet, data, ...
        all_labels, min_samples, features, repetition);
end


function [nnet, dataTest, dataTest_mat] = check_llo(nnet, data, ...
    all_labels, min_samples, features, repetition)
    
    dataTest_mat = data(:, repetition);
    data(:, repetition) = [];
    dataTest = array2table([all_labels(:, repetition)' dataTest_mat'], ...
        'VariableNames', features);
    all_labels(:, repetition) = [];
    nnet.trainParam.showWindow = false;
    [nnet, info] = train(nnet, data, all_labels);
    labelTrain = all_labels(:, info.trainInd);
    while sum(labelTrain) < min_samples || ...
            sum(labelTrain) == length(labelTrain)
        nnet = init(nnet);
        nnet.trainParam.showWindow = false;
        [nnet, info] = train(nnet, dataset, all_labels);
        labelTrain = all_labels(:, info.trainInd);
    end 
end


function [scrs, predictions] = split_prediction(nnet, dataTest_mat)
    scrs = nnet(dataTest_mat);
    scrs = [(1-scrs); scrs];
    [~, predictions] = max(scrs);
    predictions = predictions'-1;
    scrs = scrs';
end