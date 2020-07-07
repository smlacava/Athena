%% phase_lag_index 
% This function computes the phase lag index (PLI) between the signals of 
% different channels or ROIs in the input matrix.
%
% PLI = phase_lag_index(sig)
%
% INPUT:
%   sig is the input matrix (in the format time*locations)
%
% OUTPUT:
%   PLI is the matrix of the phase lag index 

function PLI = phase_lag_index(sig) 
    
    nLoc = size(sig, 2);
    PLI = zeros(nLoc, nLoc);
    complex_sig = hilbert(sig); 
 
    for i = 1:nLoc    
        for j = 1:nLoc         
            if i < j       
                PLI(i, j) = abs(mean(sign(angle(...
                    complex_sig(:, i)./complex_sig(:, j)))));                       
                PLI(j, i) = PLI(i, j);     
            end
        end
    end
end