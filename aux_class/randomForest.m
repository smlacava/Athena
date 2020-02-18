function forest = randomForest(train_data, train_labels, trees_number, test_data, test_labels)

    train_samples = length(train_labels);
    test_samples = length(test_labels);
    %error_rate_total = 0;
    %Error_stats = zeros(T, 1);
    %for n=1:100
    predict_y_test = zeros(test_samples, 1);
    predict_y_train = zeros(train_samples, 1);
    trees = cell(trees_number, 1);
    predicted = zeros(test_samples, n_trees);
    for t = 1:trees_number
        sample_ids = randsample(1:train_samples, train_samples, true);
        sample_data = train_data(sample_ids, :);
        sample_labels = train_labels(sample_ids);
        tree = decisionTreeTrain(sample_data, sample_labels);
        trees{t} = tree;
        predicted(:, t) = decisionTreePredict( test_data, tree );
end
%forest.Error_stats = Error_stats;
forest.trees = trees;
error_count = 0;
for i=1:test_samples
    if predict_y_test(i) > 0
        predict_y_test(i) = 1;
    else
        predict_y_test(i) = -1;
    end
    if predict_y_test(i) ~= test_labels(i)
        error_count = error_count + 1;
    end
end
forest.error_rate_test = error_count / test_samples;

error_count = 0;
for i=1:train_samples
    if predict_y_train(i) > 0
        predict_y_train(i) = 1;
    else
        predict_y_train(i) = -1;
    end
    if predict_y_train(i) ~= train_labels(i)
        error_count = error_count + 1;
    end
end
forest.error_rate_train = error_count / train_samples;

%error_rate_total = error_rate_total + error_count / length(Test_y);
%end
%forest.error_rate = error_rate_total/100;
end