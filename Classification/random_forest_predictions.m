%% random_forest_predictions
% This function computes the predicted classes by using a random forest
% classifier
%
% predicted = random_forest_predictions(data_test, forest)
%
% input:
%   data_test is the testing data set
%   forest is the decision trees set
%
% output:
%   predicted is the cell array which contains the predicted classes


function predicted = random_forest_predictions(data_test, forest)
    n_trees = length(forest);
    n_samples = size(data_test, 1);
    predictions = cell(1, n_trees);
    for i = 1:n_trees
        predictions{1, i} = decision_tree_predictions(data_test, ...
            forest{i});
    end
    
    predicted = cell(n_samples, 1);
    for j = 1:n_samples
        frequencies = zeros(n_classes, 1);
        pred_sample = cell(n_trees, 1);
        for i = 1:n_trees
            aux_pred = predictions{i, 1};
            pred_sample{i, 1} = aux_pred(j);
        end
        classes = unique(pred_sample);
        n_classes = length(classes);
        for i = 1:n_classes
            frequencies(i, 1) = sum(strcmp(classes{i}, pred_sample));
        end
        [~, ind] = max(frequencies);
        predicted{j, 1} = classes{ind};
    end
end
  