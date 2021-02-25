%% mst_leaf_fraction
% This function computes the leaf fraction of each node related to the 
% minimum spanning tree obtained through the Prim's algorithm.
%
% lf = mst_leaf_fraction(data, normFLAG)
%
% Input:
%   data is the (nodes x nodes) adjacency matrix
%   normFLAG has to be 1 in order to normalize the leaf fraction vector as
%       lf/max(lf) (considering lf as the leaf fraction vector), 0 
%       otherwise (1 by default)
%
% Output
%   lf is the (nodes x 1) leaf fraction vector


function lf = mst_leaf_fraction(data, normFLAG)
    if nargin < 2
        normFLAG = 1;
    end
    N = length(data);
    lf = zeros(N, 1);
    mst = minimum_spanning_tree(data);
    for i = 1:N
        for j = 1:N
            if j ~= i & mst(i, j) == 1
                lf(i) = lf(i)+double(sum(sum(mst(:, j))) == 1);
            end
        end
    end
    lf = lf/(N-1);
    
    if normFLAG == 1
        lf = value_normalization(lf, 'minmax');
    end
end
    