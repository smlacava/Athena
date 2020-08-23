%% katz_centrality
% This function computes the katz centrality.
%
% kc = katz_centrality(data, a_factor)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   a_factor is the attenuation factor
%
% Output:
%   kc is the (nodes x 1) katz centrality vector


function kc = katz_centrality(data, a_factor)
    if nargin < 2
        a_factor = 0.85;
    end
    
    data = squeeze(data);
    N = length(data);
    
    max_lambda = max(eig(data));
    a_factor = a_factor/max_lambda;
    
    aux_ones = ones(N, 1);
    id = eye(N);
    
    kc = (id - a_factor*data)\aux_ones;
end