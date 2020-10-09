%% katz_centrality
% This function computes the katz centrality (Katz, 1953: A New Status 
% Index Derived from Sociometric Index).
%
% kc = katz_centrality(data, normFLAG, a_factor)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   normFLAG has to be 1 in order to normalize the katz centrality
%       vector as kc/max(kc), 0 otherwise (1 by default)
%   a_factor is the attenuation factor
%
% Output:
%   kc is the (nodes x 1) katz centrality vector


function kc = katz_centrality(data, normFLAG, a_factor)
    if nargin < 2 || isempty(normFLAG)
        normFLAG = 1;
    end
    if nargin < 3
        a_factor = 0.85;   
    end
    
    data = squeeze(data);
    N = length(data);
    
    max_lambda = max(eig(data));
    a_factor = a_factor/max_lambda;
    
    aux_ones = ones(N, 1);
    id = eye(N);
    
    kc = (id - a_factor*data)\aux_ones;
    
    if normFLAG == 1
        kc = value_normalization(kc, 'minmax');
    end
end