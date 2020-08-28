%% clustering_coefficient
% This function computes the clustering coefficient as the mean of
% triangles associated with each node (using the algorithm proposed by 
% Onnela et al., 2005: Intensity and coherence of motifs in weighted 
% complex networks)
%
% cc = clustering_coefficient(data, normFLAG)
% 
% Input:
%   data is the (nodes x nodes) connection matrix
%   normFLAG has to be 1 in order to normalize the clustering coefficient
%       vector as cc/max(cc) (considering bc as the betweenness 
%       centrality vector and n as the number of nodes), 0 otherwise (1 by 
%       default)
%
% Output:
%   cc is the (nodes x 1) clustering coefficient vector

function cc = clustering_coefficient(data, normFLAG)

    if nargin < 2
        normFLAG = 1;
    end
    data = squeeze(data);
    
    overall_conn = sum(data ~= 0, 2);            	
    tri_cycles = diag((data.^(1/3))^3);
    overall_conn(tri_cycles == 0) = inf;
    cc = tri_cycles./(overall_conn.*(overall_conn-1));
    
    if normFLAG == 1
        cc = cc./max(cc(:));
    end
end
