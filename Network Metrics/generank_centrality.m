%% generank_centrality
% This function computes the GeneRank centrality, a variation of the 
% PageRank centrality measure (using the algorithm proposed by Morrison 
% et al., 2005: GeneRank: Using search engine technology for the analysis 
% of microarray experiments).
%
% pr = generank_centrality(data, d_factor, gr_prob)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   d_factor is the damping factor (0.85 as default)
%   gr_probability is the initial PageRank probability (vector of 1s as
%       default)
%
% Output:
%   gr is the (nodes x 1) generank centrality vector


function gr = generank_centrality(data, d_factor, gr_prob)
    
    data = squeeze(data);
    N = length(data);
    
    if nargin < 2
        d_factor = 0.85;
    end

    if nargin < 3
        norm_pr_prob = ones(N, 1)/N;
    else
        gr_prob = abs(gr_prob);
        norm_pr_prob = gr_prob/sum(gr_prob);
    end

    degrees = sum(data);
    degrees(degrees == 0) = 1;
    
    strength_inverse = zeros(N);
    strength_inverse(1:(N+1):end) = 1./degrees;
    
    base_rank = eye(N, N) - d_factor*(data*strength_inverse);
    
    aux_rank = (1-d_factor)*norm_pr_prob;
    
    gr = base_rank\aux_rank;
    gr = gr/sum(gr);
end