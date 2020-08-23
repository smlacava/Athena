%% eigenvector_centrality
% This function computes the eigenvector centrality as the eigenvector 
% associated with the largest eigenvalue of the adjacency matrix used as 
% input.
%
% ec = eigenvector_centrality(data)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%
% Output:
%   ec is the (nodes x 1) node eigenvector centrality vector


function ec = eigenvector_centrality(data)

    [V, D] = eig(squeeze(data));
    eigvals = diag(D);
    [~, idx] = max(eigvals);
    ec = squeeze(abs(V(:, idx)));

    if size(ec, 1) < size(ec, 2)
        ec = ec';
    end
end