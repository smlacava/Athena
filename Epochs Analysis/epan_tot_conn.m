%% epan_tot_conn
% This function computes the epochs analysis of a previously extracted 
% connectivity measure of a subject in every location.
%
% epan_tot_conn(data, nEpochs, nBands, measure, name, locations)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands (or the list)
%   measure is the name of the measure
%   name is the name of the analyzed subject
%   locations is the array or the matrix which contains the name of every
%       location in the first element of each row
%   save_check is 1 if the resulting figures have to be saved (0 otherwise)
%   format is the format in which the figures have to be eventually saved
%   dataPath is the data directory


function epan_tot_conn(data, nEpochs, nBands, measure, name, locations, ...
    save_check, format, dataPath)
    if nargin < 7
        save_check = 0;
        format = '';
        dataPath = '';
    end
    nLoc = length(locations);

    dim = size(data);
    if length(dim) == 3
        aux = zeros(1, dim(1), dim(2), dim(3));
        aux(1, :, :, :) = data;
        data=aux;
    end
    data = sum(data, 4)/(nLoc - 1);
    if length(size(data)) == 2 && nEpochs > 1
        for i = 1:nLoc
            ep_plot(squeeze(data(:, i)), nEpochs, measure, strcat(...
                nBands, '_', locations{i}), save_check, format, dataPath)
        end
        return
    end
    for j = 1:length(nBands)
        for i = 1:nLoc
            ep_plot(squeeze(data(j, :, i)), nEpochs, measure, strcat(...
                nBands(j), '_', locations{i}), save_check, format, ...
                dataPath)
        end
    end
end