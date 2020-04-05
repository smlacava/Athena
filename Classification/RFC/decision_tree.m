%% decision_tree
% This function fits a classification decision tree, pruning it if required
%
% tree = decision_tree(data_train, pruning_depth)
%
% input:
%   data_train is the table of the training data set
%   pruning has to be set as 1 to prune the tree model


function tree = decision_tree(data_train, pruning)
    if nargin == 1
        pruning = [];
    end
    
    tree = fitctree(data_train, "group");
    if not(isempty(pruning)) && pruning == 1
        tree = prune(tree);
    end
end

