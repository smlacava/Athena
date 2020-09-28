%% Athena_network_measures
% This function is used to list the network measures which are available in
% the Athena toolbox.
%
% network_measures = Athena_network_measures()
%
% Output:
%   network_measures is a string array which contains all the available
%       network measures


function network_measures = Athena_network_measures()
    network_measures = ["Betweenness Centrality", "Generank Centrality",...
        "Eigenvector Centrality", "Clustering Coefficient", "Strength", ...
        "Closeness Centrality", "Katz Centrality", "Subgraph Centrality"];
end