%% frequency_bands_number
% This function computes the number of frequency bands used in the study,
% through the cut frequency sentence of the text file
%
% nBands = frequency_bands_number(sentence)
%
% input:
%   sentence is the cut frequency sentence
% 
% output:
%   nBands is the number of frequency bands


function nBands = frequency_bands_number(sentence)
    bands = split(sentence, '=');
    bands = split(bands{2}, ' ');
    nBands = -1;
    for i = 1:length(bands)
        if not(isnan(str2double(bands{i})))
            nBands = nBands+1;
        end
    end
end