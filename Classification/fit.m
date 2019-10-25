function [centroids]=fit(x, y)
    n_features = size(x,2);
    n_classes = length(unique(y));
    centroids = zeros(n_classes, n_features);
    for i=1:n_classes
        centroids(i,:)=mean(x(y==i, :));
    end
end
