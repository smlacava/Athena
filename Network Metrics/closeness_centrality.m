%% closeness_centrality(data)
% This function computes the closeness centrality.
%
% cc = closeness_centrality(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   normFLAG has to be 1 in order to normalize the closeness centrality
%       vector as cc/max(cc) (considering bc as the betweenness 
%       centrality vector and n as the number of nodes), 0 otherwise (1 by 
%       default)
%
% Output
%   cc is the (nodes x 1) closeness centrality vector


function cc = closeness_centrality(data, normFLAG)

    if nargin < 2
        normFLAG = 1;
    end

    data = squeeze(data);
    N = length(data);
    
    cc = zeros(N, 1);
    id = eye(N);
    
    aux_N = N-1;
    D = data*ones(N, 1);
    
    for i = 1:N
        cc(i) = aux_N/(id(i, :)*D);
    end
    
    if normFLAG == 1
        cc = cc./max(cc(:));
    end
end
