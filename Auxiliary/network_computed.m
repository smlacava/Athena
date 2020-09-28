%% network_computed
% This function returns a string array containing the network metrics
% computed on the extracted connectivity measures.
%
% network_measures = network_computed(dataPath, measures)
%
% Input:
%   dataPath is the main directory of the study
%   measures is the list of extracted measures (optional, the list will be 
%       automatically computed if it is not provided)
%
% Output:
%   network_measures is the string list which contains the computed network 
%       metrics, in which each element is in form "measure-network metric"
%       (for example, "PLI-Betweenness Centrality")


function network_measures = network_computed(dataPath, measures)
    conn_measures = Athena_measures_list(0, 0, 1, 0);
    net_measures = Athena_network_measures();
    dataPath = path_check(dataPath);
    N = length(measures);
    network_measures = [];
    
    for i = 1:N
        if sum(strcmpi(measures(i), conn_measures)) == 1
            auxPath = strcat(dataPath, measures(i), filesep, 'Network', ...
                filesep);
            if exist(auxPath, 'dir')
                nets = dir(auxPath);
                for j = 1:length(nets)
                    if sum(strcmpi(nets(j).name, net_measures)) == 1
                        aux_net = string(strcat(measures(i), '-', ...
                            nets(j).name));
                        network_measures = [network_measures, aux_net];
                    end
                end
            end
        end
    end
end
        
        