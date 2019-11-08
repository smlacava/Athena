function [x_train, x_test, y_train, y_test]=split_data(x, y, train_samples)

    if nargin == 2
        train_samples = 0.5;
    end
    
    n = length(y);
    n_train = ceil(train_samples*n);
    
    idx = randperm(n);
    idx_train = idx(1:n_train);
    idx_test = idx(n_train+1:end);

    x_train = x(idx_train, :);
    x_test = x(idx_test, :);
    y_train = y(idx_train);
    y_test = y(idx_test);
end