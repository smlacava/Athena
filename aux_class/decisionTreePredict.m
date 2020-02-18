function [ predict_y ] = decisionTreePredict( X, tree )
%predict by the decision tree

N = length(X);
predict_y = zeros(N, 1);

for i = 1:N
    tmp_tree = tree;
    while ~tmp_tree.leaf
        feature_index = tmp_tree.condition(1,1);
        threshold = tmp_tree.condition(1,2);
        if X(i, feature_index) >= threshold
            tmp_tree = tmp_tree.left;
        else
            tmp_tree = tmp_tree.right;
        end
    end
    predict_y(i) = tmp_tree.result;
end

end