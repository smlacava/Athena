function [ tree ] = decisionTreeTrain( X, y)
%use decision tree to implement classify
% CA&T
% X: train data features
% y: train label

tree = struct('leaf',false,'condition','null','left','null','right','null','result','null');

N = size(X, 1);
d = size(X, 2);

labels = unique(y);
label_count = length(labels);

%all points y are the same, then should stop
if label_count == 1
    tree.leaf = true;
    tree.result = y(1);
    return;
end
%all points x are the same, then should stop 
if size(unique(X,'rows'), 1) == 1
    tree.leaf = true;
    tree.result = mode(y);
    return;
end

Sort_X = sort(X);

final_impurity = -1;
final_threshold = 0;
final_feature_index = 0;
final_left_X = [];
final_left_y = [];
final_right_X = [];
final_right_y = [];

for feature_index = 1:d
    for i = 1:N-1
        if Sort_X(i,feature_index) == Sort_X(i+1,feature_index)
            continue
        end
        threshold = (Sort_X(i,feature_index)+Sort_X(i+1,feature_index))/2;
        half_1_total_count = 0;
        half_2_total_count = 0;
        half_1_label_count = zeros(label_count , 1);
        half_2_label_count = zeros(label_count , 1);
        left_X = zeros(N, d);
        right_X = zeros(N, d);
        left_y = zeros(N, 1);
        right_y = zeros(N, 1);
        for j = 1:N
           if X(j, feature_index) >= threshold
               half_1_total_count = half_1_total_count + 1;
               label_index = find(labels == y(j));
               half_1_label_count(label_index) = half_1_label_count(label_index) + 1;
               left_X(half_1_total_count, :) = X(j,:);
               left_y(half_1_total_count) = y(j);
           else
               half_2_total_count = half_2_total_count + 1;
               label_index = find(labels == y(j));
               half_2_label_count(label_index) = half_2_label_count(label_index) + 1;
               right_X(half_2_total_count, :) = X(j,:);
               right_y(half_2_total_count) = y(j);
           end
        end
        %caculate purity
        half_1_impurity = 1-sum((half_1_label_count/half_1_total_count).^2);
        half_2_impurity = 1-sum((half_2_label_count/half_2_total_count).^2);
        impurity = half_1_total_count / N * half_1_impurity + half_2_total_count / N * half_2_impurity;
        if final_impurity == -1 || final_impurity > impurity
            final_impurity = impurity;
            final_feature_index = feature_index;
            final_threshold = threshold;
            final_left_X = left_X(1:half_1_total_count, :);
            final_left_y = left_y(1:half_1_total_count, :);
            final_right_X = right_X(1:half_2_total_count, :);
            final_right_y = right_y(1:half_2_total_count, :);
        end
    end
end

%iteration
tree.condition = [final_feature_index, final_threshold];
tree.left = decisionTreeTrain(final_left_X, final_left_y);
tree.right = decisionTreeTrain(final_right_X, final_right_y);

end