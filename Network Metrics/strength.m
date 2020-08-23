%% strenght
% This function computes the strength (degree centrality) of each node as 
% the sum of weights of links connected to the node itself.
%
% s = strength(data)
%
% Input:
%   data is the (nodes x nodes) connection matrix
%
% Output:
%   s is the (nodes x 1) node strength vector


function s = strength(data)
    s = sum(squeeze(data), 2);   
end