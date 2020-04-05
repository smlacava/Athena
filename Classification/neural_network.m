
function statistics = neural_network(data, n_layers, validation_value, ...
    ~, repetitions, min_samples, pca_value, eval_method, ...
    training_value, reject_value)
    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'neural_network');
    cd(char(funDir{1}));
    addpath 'NNC'
    addpath 'Performance'
    
    if nargin < 2 || isempty(n_layers)
        n_layers = 1;
    end
    if nargin < 3
        validation_value = [];
    end
    if nargin < 5 || isempty(repetitions)
        repetitions = 1;
    end
    if nargin < 6 || isempty(min_samples)
        min_samples = 1;
    end
    if nargin < 7 || isempty(pca_value)
        pca_value = 100;
    end
    if nargin < 8 || isempty(eval_method)
        eval_method = 'split';
    end
    if nargin < 9 || isempty(training_value)
        training_value = 0.8;
    end
    if nargin < 10 || isempty(reject_value) || reject_value < 0.5
        reject_value = 0.5;
    end
    rejected = [];
    
    f = waitbar(0,'Processing your data', 'Color', '[0.67 0.98 0.92]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    statistics = struct();
    data = load_classification_data(data);
    if isempty(data)
        close(f)
        return;
    end
    
    rng('default');
    bg_color = [0.67 0.98 0.92];
    nnet = patternnet(n_layers);
    
    [params_dim, scores, labels, accuracy, min_accuracy, max_accuracy, ...
        cm, n_HC, n_PAT, eval_func, testing_value, validation_value] = ...
        initial_settings('nn', data, repetitions, eval_method, ...
        training_value, validation_value);
    
    [data, pc] = reduce_predictors(data, pca_value, bg_color);
    
    for r = 1:repetitions
        [scores, labels, accuracy, min_accuracy, max_accuracy, cm, ...
            n_PAT, n_HC, rejected] = eval_func(data, ...
            validation_value, nnet, scores, labels, r, params_dim, ...
            accuracy, max_accuracy, min_accuracy, cm, n_PAT, n_HC, ...
            testing_value, min_samples, rejected, reject_value);
        waitbar(r/repetitions, f)
    end
    
    waitbar(1, f ,'Exporting data') 
    [cm, AUC, roc, conf_mat, accuracy] = ...
        performance(repetitions, cm, n_PAT, n_HC, labels, scores, ...
        accuracy, bg_color);
    statistics = nn_statistics(data, eval_method, training_value, ...
        validation_value, n_layers, repetitions, min_samples, ...
        accuracy, min_accuracy, max_accuracy, cm, conf_mat, AUC, roc, ...
        pca_value, pc, reject_value, rejected);
    close(f)
end