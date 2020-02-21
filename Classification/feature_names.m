function features = feature_names(labels, feature_name, features)
    [n_features, n_fragments] = size(labels);
    if n_fragments > 1
        n_fragments = n_fragments-1;
    end
    for i = 1:n_features
        name = '';
        for j = 1:n_fragments
            aux_label = split(labels(i, j));
            for k = 1:length(aux_label)
                name = strcat(name, char_check(aux_label(k)));
            end
        end
       features = [features, strcat(feature_name, name)];
    end
end