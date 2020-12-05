%% band_boundaries
% This function computes the minimum value and the maximum value of a
% vector of frequencies, related to the frequency values nearest to two
% different frequencies.
%
% [infft, supft] = band_boundaries(w, min_band, max_band)
%
% Input:
%   w is the vector of frequencies
%   min_band is the minimum frequency to search
%   max_band is the maximum frequency to search
%
% Output:
%   infft is the minimum frequency value
%   supft is the maximum frequency value

function [infft, supft] = band_boundaries(w, min_band, max_band)
    infft = find(w == min_band);
    if isempty(infft)
        fPre = [find(w > min_band, 1), find(w > min_band, 1)-1];
        [~, y] = min([w(fPre(1))-min_band, min_band-w(fPre(2))]);
        infft = fPre(y);
    end
        
    supft = find(w == max_band);
    if isempty(supft)
        fPost = [find(w > max_band, 1), find(w > max_band, 1)-1];
        [~, y] = min([w(fPost(1))-max_band, max_band-w(fPost(2))]);
        supft = fPost(y);
    end
end