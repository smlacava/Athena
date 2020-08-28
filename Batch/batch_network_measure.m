%% batch_network_measure
% This function is used in the batch study to extract a network metric on
% a connectivity measure.
%
% batch_network_measure(parameters)
%
% input:
%   parameters is the cell array which contains the pairs name-value for
%       each parameter used in the batch study



function batch_network_measure(parameters)
    dataPath = path_check(search_parameter(parameters, 'dataPath'));
    measure = search_parameter(parameters, 'Network_Metrics_Measure');
    normFLAG = search_parameter(parameters, 'Network_Normalization');
    if isempty(normFLAG) || strcmpi(normFLAG, 'true') || ...
            str2double(normFLAG) == 1
        normFLAG = 1;
    end
        
    network = search_parameter(parameters, 'Network_Metric');
    
    network_metrics = {'betweenness_centrality', ...
        'closeness_centrality', 'clustering_coefficient', ...
        'eigenvector_centrality', 'generank_centrality', ...
        'katz_centrality', 'strength', 'subgrap_centrality'};
    network_names = {'Betweenness Centrality', ...
        'Closeness Centrality', 'Clustering Coefficient', ...
        'Eigenvector Centrality', 'Generank Centrality', ...
        'Katz Centrality', 'Strength', 'Subgraph Centrality'};
    for i = 1:length(network_metrics)
        if strcmpi(network_names{i}, network)
            network = network_metrics{i};
            break;
        end
    end
    
    locations_file = search_parameter(parameters, 'Locations');
    network_measure(dataPath, measure, network, locations_file, normFLAG);
end
    