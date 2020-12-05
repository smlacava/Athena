%% imaginary_coherency
% This function computes the computes the imaginary component of coherency
% (ICOH) between the time series related to different locations.
% 
% ICOH = imaginary_coherency(sig)
% 
% Input:
%   sig is the EEG signal (locations x time)
%
% Output:
%   ICOH is the imaginary coherency matrix between pairs of locations 


function ICOH = imaginary_coherency(sig)

    nLoc = size(sig, 2);
    ICOH = zeros(nLoc, nLoc);
    phase = angle(hilbert(sig));
    
    for i = 1:nLoc-1
        for j = i+1:nLoc
            a = abs(sig(:, i));
            b = abs(sig(:, j));
                
            % Note that each term would be divided by the number of 
            % samples, however this can be avoided because it would be 
            % simplified in the final equation
            Cab = sum(a.*b.*sin(phase(:, i) - phase(:, j)));
            Caa = sum(a.*a);
            Cbb = sum(b.*b);
               
            ICOH(i, j) = abs(Cab/sqrt(Caa*Cbb));
            ICOH(j, i) = ICOH(i, j);
        end
    end
end
