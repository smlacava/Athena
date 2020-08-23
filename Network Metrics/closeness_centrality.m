%% closeness_centrality(data)
% This function computes the closeness centrality.
%
% cc = closeness_centrality(data)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%
% Output
%   cc is the (nodes x 1) closeness centrality vector


function cc = closeness_centrality(data)

    data = squeeze(data);
    N = length(data);
    
    cc = zeros(N, 1);
    id = eye(N);
    
    aux_N = N-1;
    D = data*ones(N, 1);
    
    for i = 1:N
        cc(i) = aux_N/(id(i, :)*D);
    end
end
