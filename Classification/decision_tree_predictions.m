%% decision_tree_predictions
% This function makes predictions over all examples of the testing data set
%
% predictions = decision_tree_predictions(data_test, tree)
%
% input:
%   data_test is the testing data set
%   tree is the decision tree model
%
% output:
%   predictions is the cell array which contains all the predicted classes


function predictions = decision_tree_predictions(data_test, tree)
    n_examples = size(data_test, 1);
    predictions = cell(n_examples, 1);
    for i = 1:n_examples
        predictions{i, 1} =predict_example(data_test(i, :), tree);
    end
end