%% magnitude_squared_coherence
% This function computes the averaged magnitude squared coherence between 
% the signals of different channels or ROIs in the input matrix.
%
% MSC = magnitude_squared_coherence(sig)
%
% INPUT:
%   sig is the input matrix (in the format time*locations)
%
% OUTPUT:
%   PLI is the matrix of the magnitude squared coherence

function MSC = magnitude_squared_coherence(sig)

    nLoc = size(sig, 2);
    MSC = zeros(nLoc, nLoc);

    for i = 1:nLoc
        for j = 1:nLoc
            if i < j
                MSC(i, j) = mean(mscohere(sig(:, i), sig(:, j)));    
                MSC(j, i) = MSC(i, j);     
            end
        end
    end
end