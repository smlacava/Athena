%% amplitude_envelope_correlation_orth
% This function computes the orthogonalized amplitude envelope correlation 
% (AECo) between the signals of different channels or ROIs in the input
% matrix.
%
%   AECo = amplitude_envelope_correlation_orth(sig)
%
% INPUT:
%   sig is the input matrix (in the format time*locations)
%
% OUTPUT:
%   AECo is the matrix of the orthogonalized amplitude envelope correlation

function AECo = amplitude_envelope_correlation_orth(sig)
    nLoc = size(sig, 2);
    AECo = zeros(nLoc, nLoc);
    complex_sig = hilbert(sig);

    for i = 1:nLoc-1
        for j = i+1:nLoc     
            ort1 = orthog_timedomain(sig(:, i), sig(:, j));
            complex_ort1 = abs(hilbert(ort1));
            AEC1 = abs(corrcoef(complex_ort1, abs(complex_sig(:, i))));
        
            ort2 = orthog_timedomain(sig(:, j), sig(:, i));
            complex_ort2 = abs(hilbert(ort2));
            AEC2 = abs(corrcoef(complex_ort2, abs(complex_sig(:, j))));
        
            AEC_mean = (AEC1(1, 2)+AEC2(1, 2))/2;        
            AECo(i, j) = AEC_mean;                
            AECo(j, i) = AECo(i, j);        
        end       
    end
end