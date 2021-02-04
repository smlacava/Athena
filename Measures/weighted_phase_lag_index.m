%% weightes_phase_lag_index 
% This function computes the weighted phase lag index (wPLI) between the 
% signals of different channels or ROIs in the input matrix.
%
% wPLI = weighted_phase_lag_index(sig)
%
% INPUT:
%   sig is the input matrix (in the format time*locations)
%
% OUTPUT:
%   wPLI is the connectivity matrix

function wPLI = weighted_phase_lag_index(sig) 
    
    nLoc = size(sig, 2);
    wPLI = zeros(nLoc, nLoc);
    complex_sig = hilbert(sig); 
 
    for i = 1:nLoc-1
        for j = i+1:nLoc       
            img = angle(complex_sig(:, i)./complex_sig(:, j));
            wPLI(i, j) = abs(sum(abs(img).*sign(img))/sum(abs(img)));            
            wPLI(j, i) = wPLI(i, j);
        end
    end
end