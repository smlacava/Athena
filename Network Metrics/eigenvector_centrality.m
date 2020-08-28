%% eigenvector_centrality
% This function computes the eigenvector centrality as the eigenvector 
% associated with the largest eigenvalue of the adjacency matrix used as 
% input.
%
% ec = eigenvector_centrality(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   normFLAG has to be 1 in order to normalize the eigenvector centrality
%       vector as ec/max(ec), 0 otherwise (1 by default)
%
% Output:
%   ec is the (nodes x 1) node eigenvector centrality vector


function ec = eigenvector_centrality(data, normFLAG)

    if nargin < 2
        normFLAG = 1;
    end

    [V, D] = eig(squeeze(data));
    eigvals = diag(D);
    [~, idx] = max(eigvals);
    ec = squeeze(abs(V(:, idx)));

    if size(ec, 1) < size(ec, 2)
        ec = ec';
    end
    
    if normFLAG == 1
        ec = ec./max(ec);
    end
end