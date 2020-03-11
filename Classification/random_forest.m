%% random_forest
% This function fits a random forest classifier and tests a data set on it
% for a selected number of times, and computes the averaged accuracy, the
% minimum accuracy, the maximum accuracy and shows the averaged confusion
% matrix, and the overall ROC curve and AUC value
%
% statistics = random_forest(data, split_value, n_trees, ...
%       bagging_value, random_subspace_value, pruning, ...
%       n_repetitions, min_samples, pca_value)
%
% input:
%   data is the data set table
%   split_value is the fraction of training data set (a number comprised
%       between 0 and 1, 0.8 as default)
%   n_trees is the number of trees for each random forest classifier (1 as
%       default)
%   bagging_value is the fraction of training data set to use in training
%       each tree (1 as default)
%   pruning is 'on' if each tree has to be pruned (0, or 'off', as default)
%   n_repetitions is the number of repetition of the
%       training/testing process (1 as default)
%   min_samples is the minimum number of examples of each class in the
%       training data set (1 as default)
%   pca_value is the variance percentage threshold to reduce the number of
%       predictors through the principal component analysis
%
% output:
%   statistic is the resulting structure which contains the used parameters
%       and the resulting performance


function statistics = random_forest(data, split_value, n_trees, ...
    bagging_value, pruning, n_repetitions, min_samples, pca_value)
    
    if nargin < 2
        split_value = 0.8;
    end
    if nargin < 3
        n_trees = 1;
    end
    if nargin < 4
        bagging_value = [];
    end
    if nargin < 5 
        pruning = [];
    end
    if nargin < 6
        n_repetitions = 1;
    end
    if nargin < 7
        min_samples = 1;
    end
    if nargin < 8
        pca_value = 100;
    end
    
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
    [testing_fraction, params_dim, scores, labels, pruning, ...
        accuracy, min_accuracy, max_accuracy, cm, n_HC, n_PAT] = ...
        rf_initial_settings(data, split_value, n_repetitions, pruning);
     
    if min(size(data)) == 1
        problem('There are not enough parameters to evaluate')
        return;
    end
    
    [data, pc] = reduce_predictors(data, pca_value, bg_color);
    
    t = templateTree('Prune', pruning);
    
    if split_value > 1
        split_value = split_value/n_cases;
    end
    for r = 1:n_repetitions
        [dataTrain, dataTest] = split_data(data, testing_fraction, ...
            min_samples);
        mdl = fitcensemble(dataTrain, 'group', 'Method', 'Bag', ...
            'Learners', t, 'FResample', bagging_value, ...
            'NumLearningCycles', n_trees);
        [predictions, scrs] = predict(mdl, dataTest);
        [scores, labels] = roc_update(scores, labels, scrs, ...
            dataTest.group, r, params_dim);  
        [accuracy, min_accuracy, max_accuracy] = accuracy_update(...
            predictions, dataTest.group, accuracy, max_accuracy, ...
            min_accuracy);
        [cm, n_PAT, n_HC] = confusion_matrix_update(predictions, ...
            dataTest.group, cm, n_PAT, n_HC);
        waitbar(r/n_repetitions, f)
    end
    
    waitbar(1, f ,'Exporting data')    
     
    accuracy = accuracy/n_repetitions;
    cm(1, :) = cm(1, :)/n_PAT;
    cm(2, :) = cm(2, :)/n_HC;
    [AUC, roc] = ROC_curve(labels, scores, bg_color);
    conf_mat = confusion_matrix(cm, accuracy, bg_color);
    
    statistics = rf_statistics(split_value, n_trees, bagging_value, ...
        pruning, n_repetitions, min_samples, accuracy, min_accuracy, ...
        max_accuracy, cm, conf_mat, AUC, roc, pca_value, pc);
    close(f)
end