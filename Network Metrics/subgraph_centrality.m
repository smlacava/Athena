%% subgraph_centrality
% This function computes the Subgraph centrality (or communicability) of 
% each node, considering the adjacency matrix (Estrada E. and 
% Rodriguez-Velazquez J. A., 2005: Subgraph centrality in complex networks; 
% Estrada E. and Hatano N., 2008: Communicability in complex networks).
%
% sgc = subgraph_centrality(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   normFLAG has to be 1 in order to normalize the subgraph centrality
%       vector as sgc/max(sgc), 0 otherwise (1 by default)
%
% Output:
%   sgc is the (nodes x 1) subgraph centrality vector


function sgc = subgraph_centrality(data, normFLAG)
    if nargin < 2
        normFLAG = 1;
    end
    
    data = squeeze(data);
    N = length(data);
    D = eye(N);
    D(1:N+1:N*N) = 1.0./sqrt(D(1:N+1:N*N)); % weights normalization
    data_norm = D*data*D;
    sgc = expm(data_norm);
    sgc = sgc(1:N+1:N*N);
    
    if normFLAG == 1
        sgc = value_normalization(sgc, 'minmax');
    end
end