%% correlation_coefficient
% This function computes the correlation coefficient (CC) between the 
% signals of different channels or ROIs in the input matrix, returning the
% related absolute value for each pair.
%
% PLI = correlation_coefficient(sig)
%
% INPUT:
%   sig is the input matrix (in the format time x locations)
%
% OUTPUT:
%   CC is the matrix of the correlation coefficient 

function CC = correlation_coefficient(sig) 
    
    nLoc = size(sig, 2);
    CC = zeros(nLoc, nLoc);
 
    for i = 1:nLoc-1
        for j = i+1:nLoc
            corr_mat = corrcoef(sig(:, i), sig(:, j));
            CC(i, j) = abs(corr_mat(2));                       
            CC(j, i) = CC(i, j);     
        end
    end
end