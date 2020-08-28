%% strenght
% This function computes the strength (degree centrality) of each node as 
% the sum of weights of links connected to the node itself.
%
% s = strength(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) connection matrix
%   normFLAG has to be 1 in order to normalize the strength vector as
%       s/max(s), 0 otherwise (1 by default)
%
% Output:
%   s is the (nodes x 1) node strength vector


function s = strength(data, normFLAG)
    if nargin < 2
        normFLAG = 1;
    end
    
    s = sum(squeeze(data), 2);  
    
    if normFLAG == 1
        s = s./max(s);
    end
end