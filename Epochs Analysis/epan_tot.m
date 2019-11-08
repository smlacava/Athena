%% epan_tot
% This function computes the epochs analysis of a previously extracted 
% not-connectivity measure of a subject every location.
%
% epan_tot(data, nEpochs, nBands, measure, name, locations)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands
%   measure is the name of the measure
%   name is the name of the analyzed subject
%   locations is the array or the matrix which contains the name of every
%       location in the first element of each row

function epan_tot(data, nEpochs, nBands, measure, name, locations)
    
    nLoc = length(locations);

    dim = size(data);
    if length(dim) == 2
        aux = zeros(1, dim(1), dim(2));
        aux(1, :, :) = data;
        data = aux;
    end
    for i = 1:nLoc
        ep_scatter(data(:, :, i), nEpochs, nBands, ...
            strcat(char_check(name), ' ', char_check(locations(i, 1))), ...
            measure)
    end
end