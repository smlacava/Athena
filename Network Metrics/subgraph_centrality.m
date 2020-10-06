%% subgraph_centrality
% This function computes the Subgraph centrality of each node, considering
% the adjacency matrix.
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
    exp_data = expm(data);
    sgc = exp_data(1:N:end)';
    
    if normFLAG == 1
        sgc = value_normalization(sgc, 'minmax');
    end
end