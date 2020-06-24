%% epan_asy
% This function computes the epochs analysis of a previously extracted 
% not-connectivity measure of the asymmetry of a subject.
%
% epan_areas(data, nEpochs, nBands, measure, name, RightLoc, LeftLoc)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands (or the list)
%   measure is the name of the measure
%   name is the name of the analyzed subject
%   RightLoc is the array which contains the indexes of the locations in
%       the right hemisphere
%   LeftLoc is the array which contains the indexes of the locations in
%       the left hemisphere

function epan_asy(data, nEpochs, nBands, measure, name, RightLoc, LeftLoc)
    
    dim = size(data);
    if length(dim) == 2
        aux = zeros(1, dim(1), dim(2));
        aux(1, :, :) = data;
        data = aux;
    end
    bands = nBands;
    if iscell(nBands) || isstring(nBands)
        nBands = length(bands);
    end
    
    data_asy = zeros(nBands, nEpochs, 2);
    data_asy(:, :, 1) = mean(data(:, :, RightLoc), 3);
    data_asy(:, :, 2) = mean(data(:, :, LeftLoc), 3);
    asy = abs(data_asy(:, :, 1)-data_asy(:, :, 2));
    
    nBands = bands;
    ep_scatter(asy, nEpochs, nBands, ...
        strcat(char_check(name), ' Asymmetry'), measure)
end
        
