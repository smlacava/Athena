function data_train = random_subspace(data_train, random_subspace_value)
    if isempty(random_subspace_value)
        random_subspace_value = 0.8;
    end

    n_features = size(data_train, 2)-1;
    if random_subspace_value < 1
        random_subspace_value = ceil(random_subspace_value*n_features);
    end
    if random_subspace_value < n_features
        index_features = randperm(n_features);
        index_features(1:random_subspace_value) = [];
        data_train(:, index_features+1) = [];
    end
end