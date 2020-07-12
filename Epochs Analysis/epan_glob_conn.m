%% epan_glob_conn
% This function computes the global epochs analysis of a previously
% extracted connectivity measure of a subject.
%
% epan_glob_conn(data, nEpochs, nBands, measure, name, save_check, ...
%         format, dataPath)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands (or the list)
%   measure is the name of the measure
%   name is the name of the analyzed subject
%   save_check is 1 if the resulting figures have to be saved (0 otherwise)
%   format is the format in which the figures have to be eventually saved
%   dataPath is the data directory

function epan_glob_conn(data, nEpochs, nBands, measure, name, ...
    save_check, format, dataPath)
    if nargin < 6
        save_check = 0;
        format = '';
        dataPath = '';
    end
    dim = size(data);
    if length(dim) == 3
        aux = zeros(1, dim(1), dim(2), dim(3));
        aux(1, :, :) = data;
        data = aux;
    end
    
    glob = squeeze(sum(data, [3 4])/(dim(3)*dim(3)-dim(3)));
    
    ep_scatter(glob, nEpochs, nBands, ...
        strcat(char_check(name), " Global"), measure, save_check, ...
        format, dataPath)
end