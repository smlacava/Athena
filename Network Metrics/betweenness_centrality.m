%% betweenness_centrality
% This function computes the node betweenness centralitty as the fraction
% as the fraction of all shortest paths in the network that contains a
% given node (using the algorithm proposed by Brandes, 2000: A faster 
% algorithm for betweenness centrality)
%
% bc = betweenness_centrality(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) binary connection matrix
%   normFLAG has to be 1 in order to normalize the betweenness centrality
%       vector as bc/max(bc), 0 otherwise (1 by default)
%
% Output:
%   bc is the (nodes x 1) node betweenness centrality vector

function bc = betweenness_centrality(data, normFLAG)
    if nargin < 2
        normFLAG = 1;
    end
    
    data = squeeze(data);
    n = length(data);
    bc = zeros(n, 1);
    
    for x = 1:n
        distance = inf(1, n); 
        distance(x) = 0;
        paths_number = zeros(1, n); 
        paths_number(x) = 1;     
        distance_permanence = true(1, n);
        predecessors = false(n, n);
        aux_matrix = zeros(1, n); 
        order = n;
        
        aux_data = data;
        aux_x = x;
        while 1
            distance_permanence(aux_x) = 0;
            aux_data(:, aux_x) = 0;
            for y = aux_x
                aux_matrix(order) = y; 
                order = order-1;
                neighbours = find(aux_data(y, :));
                for neigh = neighbours
                    [distance, paths_number, predecessors] = ...
                        paths_update(aux_data, distance, paths_number, ...
                        predecessors, y, neigh);
                end
            end
            
            min_distance = min(distance(distance_permanence));
            if isempty(min_distance)
                break             
            elseif isinf(min_distance)                  
                aux_matrix(1:order) = find(isinf(distance)); 
                break
            end
            aux_x = find(distance == min_distance);
        end
        
        bc = betweenness_centrality_update(bc, predecessors, ...
            paths_number, n, aux_matrix);
    end
    if normFLAG == 1
        bc = bc./max(bc(:));
    end
end


%% paths_update
% This function updates the distance from the neighbours and the number of
% paths of a given node, and updated the predecessors matrix, verifying if
% a given node has a shorter path from the analyzed node than the current
% nodes considered as nearest ones.
%
% [distance, paths_number, predecessors] = paths_update(aux_data, ...
%        distance, paths_number, predecessors, y, neigh)
%
% Input:
%   data is the data matrix
%   distance is the distance vector
%   paths_number is the vector which contains the number of shortest paths
%       of a given node
%   predecessors is the matrix which explains if a node is a predecessor of
%       another node (1) or not (0)
%   y is the analyzed node index
%   neigh is the analyzed neighbor index
%
% Output:
%   distance is the updated distance vector
%   paths_number is the updated shortest paths vector
%   predecessors is the updated predecessors matrix


function [distance, paths_number, predecessors] = ...
    paths_update(data, distance, paths_number, predecessors, y, neigh)
    distance_xy = distance(y)+data(y, neigh);
    if distance_xy < distance(neigh)
        distance(neigh) = distance_xy;
        paths_number(neigh) = paths_number(y);
        predecessors(neigh, :) = 0;
        predecessors(neigh, y) = 1;
    elseif distance_xy == distance(neigh)
        paths_number(neigh) = paths_number(neigh)+paths_number(y);
        predecessors(neigh, y) = 1;
    end
end



%% betweenness_centrality_update
% This function updates the betweenness centrality matrix by computing the
% dependency related to each neighbour.
%
% bc = betweenness_centrality_update(bc, predecessors, paths_number, n, ...
%         aux_matrix)
%
% Input:
%   bc is the betweenness centrality matrix
%   predecessors is the predecessors matrix
%   paths_number is the vector which contains the number of shortest paths
%       of a given node
%   n is the number of nodes
%   aux_matrix is an auxiliarly matrix 
%
% Output:
%   bc is the updated betweenness centrality matrix

function bc = betweenness_centrality_update(bc, predecessors, ...
    paths_number, n, aux_matrix)

    dependency = zeros(n, 1);
    for neigh = aux_matrix(1:n-1)
        bc(neigh) = bc(neigh)+dependency(neigh);
        for y = find(predecessors(neigh, :))
            to_add = (1+dependency(neigh)).*paths_number(y);
            to_add_weighted = to_add./paths_number(neigh);
            dependency(y) = dependency(y)+to_add_weighted;
        end
    end
end