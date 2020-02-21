function data_train = bagging(data_train, bagging_value)
    if isempty(bagging_value)
        bagging_value = 0.8;
    end

    n_subjects = size(data_train, 1);
    if bagging_value < 1
        bagging_value = ceil(bagging_value*n_subjects);
    end
    if bagging_value < n_subjects
        index_subjects = randi(n_subjects, bagging_value, 1);
        data_train = data_train(index_subjects, :);
    end
end

