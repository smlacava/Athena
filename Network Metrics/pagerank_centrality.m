%% pagerank_centrality
% This function computes the PageRank centrality related to a connectivity
% matrix.
%
% prc = pagerank_centrality(data, normFlag, d)
%
% Input:
%   data is the (N x N) connectivity matrix
%   normFlag has to be 1 in order to normalize the resulting PageRank
%       centrality, 0 otherwise
%   d is the dumping factor (0.85 by default)
%
% Output:
%   prg is the (N x 1) pagerank array

function prc = pagerank_centrality(data, normFlag, d)
    if nargin < 2
        normFlag = 1;
    end
    if nargin < 3
        d = 0.85;
    end
    qerror = 0.001;
    
    data = squeeze(data);
    N = length(data);
    
    %For satisfying data*ones(N)=ones(N)
    for i = 1:N
        data(i, :) = data(i, :)/sum(data(i, :));
    end
    
    
    prc = rand(N, 1);
    prc = prc./norm(prc, 1);
    last_v = ones(N, 1)*inf;
    M = (d.*data')+(((1-d)/N).*ones(N));
    
    while (norm(prc-last_v, 2) > qerror)
        last_v = prc;
        prc = M * prc;
    end
    prc = prc/max(prc);
    if normFlag == 1
        prc = prc/sum(prc);
    end
end