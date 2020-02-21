function [tree] = decision_tree(data_train, bagging_value, ...
    random_subspace_value, pruning_depth)
    tree = fitctree(data_train, "group");
    if not(isempty(pruning_depth))
        tree = prune(tree);
    end
end

