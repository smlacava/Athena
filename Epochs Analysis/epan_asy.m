%% epan_asy
% This function computes the epochs analysis of a previously extracted 
% not-connectivity measure of the asymmetry of a subject.
%
% epan_areas(data, nEpochs, nBands, measure, name, RightLoc, LeftLoc, ...
%         save_check, format, dataPath)
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
%   save_check is 1 if the resulting figures have to be saved (0 otherwise)
%   format is the format in which the figures have to be eventually saved
%   dataPath is the data directory

function epan_asy(data, nEpochs, nBands, measure, name, RightLoc, ...
    LeftLoc, save_check, format, dataPath)
    if nargin < 8
        save_check = 0;
        format = '';
        dataPath = '';
    end
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
    data = abs(data_asy(:, :, 1) - data_asy(:, :, 2));
    
    nBands = bands;
    if length(size(data)) == 1 && nEpochs > 1
        ep_plot(squeeze(data), nEpochs, measure, strcat(...
            nBands, '_asymmetry'), save_check, format, dataPath)
        return
    end
    for j = 1:length(nBands)
        ep_plot(squeeze(data(j, :)), nEpochs, measure, strcat(...
            nBands(j), '_asymmetry'), save_check, format, dataPath)
    end
end
        
