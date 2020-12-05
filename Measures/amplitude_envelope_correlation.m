%% amplitude_envelope_correlation
% This function computes the amplitude envelope correlation (AEC) between
% the signals of different channels or ROIs in the input matrix.
%
%   AEC = amplitude_envelope_correlation(sig)
%
% INPUT:
%   sig is the input matrix (in the format time*locations)
%
% OUTPUT:
%   AEC is the amplitude envelope correlation

function AEC = amplitude_envelope_correlation(sig)

    nLoc = size(sig, 2);
    AEC = zeros(nLoc, nLoc);
    complex_sig = hilbert(sig);

    for i = 1:nLoc-1
        for j = i+1:nLoc        
            AEC1 = abs(corrcoef(abs(complex_sig(:, j)), ...
                abs(complex_sig(:, i))));        
            AEC_mean = AEC1(1, 2);        
            AEC(i, j) = AEC_mean;       
            AEC(j, i) = AEC(i, j);        
        end
    end
end