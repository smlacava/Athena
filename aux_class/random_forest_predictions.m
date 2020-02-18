function predictions = random_forest_predictions(trees_predictions)
    n_samples = size(trees_predictions, 1);
    predictions = zeros(n_samples, 1);
    for i = 1:n_samples
        classes = unique(trees_predictions(i, :));
        n_classes = zeros(length(classes));
        frequencies = zeros(n_classes);
        for j = 1:n_classes
            frequencies(j) = sum(trees_predictions(i, :) == classes(j));
        end
        [~, c] = max(frequencies);
        predictions(j) = classes(c);
    end
end

