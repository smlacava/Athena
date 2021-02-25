%% mst_degree
% This function computes the degree of each node related to the minimum 
% spanning tree obtained through the Prim's algorithm.
%
% d = mst_degree(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   normFLAG has to be 1 in order to normalize the degree vector as
%       d/max(d) (considering d as the minimum spanning tree's degree and
%       n as the number of nodes), 0 otherwise (1 by default)
%
% Output
%   d is the (nodes x 1) minimum spanning tree's degree vector


function d = mst_degree(data, normFLAG)
    if nargin < 2
        normFLAG = 1;
    end
    N = length(data)-1;
    mst = minimum_spanning_tree(data);
    d = sum(mst, 2)/N;
    
    if normFLAG == 1
        d = value_normalization(d, 'minmax');
    end
end
    