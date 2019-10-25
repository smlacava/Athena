function y_pred=predict(x, centroids)
    n_classes = size(centroids,2);
    n_samples = size(x,1);
    dist = zeros(n_samples, n_classes);
    y_pred=zeros(n_samples, 1);
    for i=1:n_classes
        dist(:,i) = norm(x-centroids(i,:));
    end
    for i=1:n_samples
        [m,y_pred(i,1)] = min(dist, [], 2)-1;
    end
end