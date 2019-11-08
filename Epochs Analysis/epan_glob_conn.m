%% epan_glob_conn
% This function computes the global epochs analysis of a previously
% extracted connectivity measure of a subject.
%
% epan_glob_conn(data, nEpochs, nBands, measure, name)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands
%   measure is the name of the measure
%   name is the name of the analyzed subject

function epan_glob_conn(data, nEpochs, nBands, measure, name)
    dim = size(data);
    if length(dim) == 3
        aux = zeros(1, dim(1), dim(2), dim(3));
        aux(1, :, :) = data;
        data = aux;
    end
    
    glob = squeeze(sum(data, [3 4])/(dim(3)*dim(3)-dim(3)));
    
    ep_scatter(glob, nEpochs, nBands, ...
        strcat(char_check(name), ' Global'), measure)
end