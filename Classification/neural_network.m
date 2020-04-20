%% neural_network
% This function fits a neural network classifier and tests a data set on it
% for a selected number of times, and computes the averaged accuracy, the
% minimum accuracy, the maximum accuracy and shows the averaged confusion
% matrix, and the overall ROC curve and AUC value
%
% statistics = neural_network(data, n_layers, validation_value, ~, ...
%    repetitions, min_samples, pca_value, eval_method, training_value, ...
%    reject_value)
%
% input:
%   data is the data set table
%   n_layers is the number of hidden layers
%   validation_value is the fraction of dataset to use as validation set
%   ~ can take every value (it is not used)
%   min_samples is the minimum number of examples of each class in the
%       training data set (1 as default)
%   pca_value is the variance percentage threshold to reduce the number of
%       predictors through the principal component analysis
%   eval_method is the evaluation method, which can be 'split' to randomly
%       split the dataset in training set and test set or 'leaveoneout' to
%       train the classifier on all the samples except one used to test
%       iterating for all the samples ('split' by default)
%   trsining_value is the fraction of training data set (a number comprised
%       between 0 and 1, 0.8 as default)
%   reject_value is the percentage is the minimum probability of 
%       classification relative to the assigned class, under which the 
%       sample is rejected
%
% output:
%   statistic is the resulting structure which contains the used parameters
%       and the resulting performance


function statistics = neural_network(data, n_layers, validation_value, ...
    ~, repetitions, min_samples, pca_value, eval_method, ...
    training_value, reject_value)
    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'neural_network');
    cd(char(funDir{1}));
    addpath 'NNC'
    addpath 'Performance'
    
    if nargin < 2 || isempty(n_layers)
        n_layers = 1;
    end
    if nargin < 3
        validation_value = [];
    end
    if nargin < 5 || isempty(repetitions)
        repetitions = 1;
    end
    if nargin < 6 || isempty(min_samples)
        min_samples = 1;
    end
    if nargin < 7 || isempty(pca_value)
        pca_value = 100;
    end
    if nargin < 8 || isempty(eval_method)
        eval_method = 'split';
    end
    if nargin < 9 || isempty(training_value)
        training_value = 0.8;
    end
    if nargin < 10 || isempty(reject_value) || reject_value < 0.5
        reject_value = 0.5;
    end
    rejected = [];
    
    f = waitbar(0,'Processing your data', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    statistics = struct();
    data = load_classification_data(data);
    if isempty(data)
        close(f)
        return;
    end
    
    rng('default');
    bg_color = [1 1 1];
    nnet = patternnet(n_layers);
    
    [params_dim, scores, labels, accuracy, min_accuracy, max_accuracy, ...
        cm, n_HC, n_PAT, eval_func, testing_value, validation_value] = ...
        initial_settings('nn', data, repetitions, eval_method, ...
        training_value, validation_value);
    
    [data, pc] = reduce_predictors(data, pca_value, bg_color);
    
    for r = 1:repetitions
        [scores, labels, accuracy, min_accuracy, max_accuracy, cm, ...
            n_PAT, n_HC, rejected] = eval_func(data, ...
            validation_value, nnet, scores, labels, r, params_dim, ...
            accuracy, max_accuracy, min_accuracy, cm, n_PAT, n_HC, ...
            testing_value, min_samples, rejected, reject_value);
        waitbar(r/repetitions, f)
    end
    
    waitbar(1, f ,'Exporting data') 
    [cm, AUC, roc, conf_mat, accuracy] = ...
        performance(repetitions, cm, n_PAT, n_HC, labels, scores, ...
        accuracy, bg_color);
    statistics = nn_statistics(data, eval_method, training_value, ...
        validation_value, n_layers, repetitions, min_samples, ...
        accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
        pca_value, pc, reject_value, rejected);
    close(f)
end