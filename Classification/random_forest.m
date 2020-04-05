%% random_forest
% This function fits a random forest classifier and tests a data set on it
% for a selected number of times, and computes the averaged accuracy, the
% minimum accuracy, the maximum accuracy and shows the averaged confusion
% matrix, and the overall ROC curve and AUC value
%
% statistics = random_forest(data, n_trees, resample_value, pruning, ...
%       n_repetitions, min_samples, pca_value, eval_method, ...
%       split_value, reject_option)
%
% input:
%   data is the data set table
%   n_trees is the number of trees for each random forest classifier (1 as
%       default)
%   resample_value is the fraction of training data set to use in training
%       each tree (1 as default)
%   pruning is 'on' if each tree has to be pruned (0, or 'off', as default)
%   repetitions is the number of repetition of the fitting/testing process 
%       (1 as default)
%   min_samples is the minimum number of examples of each class in the
%       training data set (1 as default)
%   pca_value is the variance percentage threshold to reduce the number of
%       predictors through the principal component analysis
%   eval_method is the evaluation method, which can be 'split' to randomly
%       split the dataset in training set and test set or 'leaveoneout' to
%       train the classifier on all the samples except one used to test
%       iterating for all the samples ('split' by default)
%   split_value is the fraction of training data set (a number comprised
%       between 0 and 1, 0.8 as default)
%   reject_value is the percentage is the minimum probability of 
%       classification relative to the assigned class, under which the 
%       sample is rejected
%
% output:
%   statistic is the resulting structure which contains the used parameters
%       and the resulting performance


function statistics = random_forest(data, n_trees, resample_value, ...
    pruning, repetitions, min_samples, pca_value, eval_method, ...
    split_value, reject_value)
    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'random_forest');
    cd(char(funDir{1}));
    addpath 'RFC'
    addpath 'Performance'
    
    if nargin < 2 || isempty(n_trees)
        n_trees = 1;
    end
    if nargin < 3
        resample_value = [];
    end
    if nargin < 4
        pruning = [];
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
    if nargin < 9 || isempty(split_value)
        split_value = 0.8;
    end
    if nargin < 10 || isempty(reject_value) || reject_value < 0.5
        reject_value = 0.5;
    end
    rejected = [];
    
    f = waitbar(0,'Processing your data', 'Color', '[0.67 0.98 0.92]');
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
    bg_color = [0.67 0.98 0.92];
    [params_dim, scores, labels, accuracy, min_accuracy, max_accuracy, ...
        cm, n_HC, n_PAT, eval_function, testing_fraction, pruning] = ...
        initial_settings('rf', data, repetitions, eval_method, ...
        split_value, pruning);
     
    if min(size(data)) == 1
        close(f)
        problem('There are not enough parameters to evaluate')
        return;
    end
    
    [data, pc] = reduce_predictors(data, pca_value, bg_color);
    
    t = templateTree('Prune', pruning);
    
    if split_value > 1
        split_value = split_value/n_cases;
    end
    for r = 1:repetitions
        [scores, labels, accuracy, min_accuracy, max_accuracy, cm, ...
            n_PAT, n_HC, rejected] = eval_function(data, ...
            resample_value, t, n_trees, scores, labels, r, params_dim, ...
            accuracy, max_accuracy, min_accuracy, cm, n_PAT, n_HC, ...
            testing_fraction, min_samples, rejected, reject_value);
        waitbar(r/repetitions, f)
    end
    
    waitbar(1, f ,'Exporting data')    
     
    [cm, AUC, roc, conf_mat, accuracy] = ...
        performance(repetitions, cm, n_PAT, n_HC, labels, scores, ...
        accuracy, bg_color);
    
    statistics = rf_statistics(data, eval_method, split_value, ...
        n_trees, resample_value, pruning, repetitions, min_samples, ...
        accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
        pca_value, pc, reject_value, rejected);
    close(f)
end