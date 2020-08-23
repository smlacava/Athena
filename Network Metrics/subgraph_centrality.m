%% subgraph_centrality
% This function computes the Subgraph centrality of each node, considering
% the adjacency matrix.
%
% sgc = subgraph_centrality(data)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%
% Output:
%   sgc is the (nodes x 1) subgraph centrality vector


function sgc = subgraph_centrality(data)
    data = squeeze(data);
    N = length(data);
    exp_data = expm(data);
    sgc = exp_data(1:N:end)';
end