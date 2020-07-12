%% epan_asy_conn
% This function computes the epochs analysis of a previously extracted 
% connectivity measure of the asymmetry of a subject.
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

function epan_asy_conn(data, nEpochs, nBands, measure, name, RightLoc, ...
    LeftLoc, save_check, format, dataPath)
    if nargin < 8
        save_check = 0;
        format = '';
        dataPath = '';
    end
    R = length(RightLoc);
    R = R*R-R;
    L = length(LeftLoc);
    L = L*L-L;
    
    dim = size(data);
    if length(dim) == 3
        aux = zeros(1, dim(1), dim(2), dim(3));
        aux(1, :, :, :) = data;
        data = aux;
    end
    bands = nBands;
    if iscell(nBands) || isstring(nBands)
        nBands = length(bands);
    end
    
    idx = conn_index(data);
    
    data_asy = zeros(nBands, nEpochs, 2);
    data_asy(:, :, 1) = sum(squeeze(sum(...
        data(:, :, RightLoc, RightLoc), 3)), idx)/R;
    data_asy(:,:,2) = sum(squeeze(...
        sum(data(:, :, LeftLoc, LeftLoc), 3)), idx)/L;
    asy = abs(data_asy(:, :, 1)-data_asy(:, :, 2));
    
    nBands = bands;
    ep_scatter(asy, nEpochs, nBands, ...
        strcat(char_check(name), " Asymmetry"), measure, save_check, ...
        format, dataPath)