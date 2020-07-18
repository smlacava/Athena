%% epan_areas_conn
% This function computes the epochs analysis of a previously extracted 
% connectivity measure of a subject in frontal, temporal, central,
% occipital and parietal areas.
%
% epan_areas_conn(data, nEpochs, nBands, measure, name, CentralLoc, ...
%       FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands (or the list)
%   measure is the name of the measure
%   name is the name of the analyzed subject
%   CentralLoc is the array which contains the indices of every central
%       location
%   FrontalLoc is the array which contains the indices of every frontal
%       location
%   TemporalLoc is the array which contains the indices of every temporal
%       location
%   OccipitalLoc is the array which contains the indices of every occipital
%       location
%   ParietalLoc is the array which contains the indices of every parietal
%       location
%   save_check is 1 if the resulting figures have to be saved (0 otherwise)
%   format is the format in which the figures have to be eventually saved
%   dataPath is the data directory

function epan_areas_conn(data, nEpochs, nBands, measure, name, ...
    CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, ...
    save_check, format, dataPath)
    if nargin < 11
        save_check = 0;
        format = '';
        dataPath = '';
    end
    
    Front = length(FrontalLoc);
    Front = Front*Front-Front;
    Temp = length(TemporalLoc);
    Temp = Temp*Temp-Temp;
    Occ = length(OccipitalLoc);
    Occ = Occ*Occ-Occ;
    Par = length(ParietalLoc);
    Par = Par*Par-Par;
    Cent = length(CentralLoc);
    Cent = Cent*Cent-Cent;
    areas = string();
    nLoc = 0;

    if Front ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Frontal"];
    end
    if Temp ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Temporal"];
    end
    if Occ ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Occipital"];
    end
    if Par ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Parietal"];
    end
    if Cent ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Central"];
    end
    areas(1) = [];
    
    dim = size(data);
    if length(dim) == 3
        aux = zeros(1, dim(1), dim(2), dim(3));
        aux(1, :, :, :) = data;
        data = aux;
    end
    
    idx = conn_index(data);
    
    loc = 1;
    if Front ~= 0
        data_areas(:, :, loc) = sum(squeeze(sum(...
            data(:, :, FrontalLoc, FrontalLoc), 3)), idx)/Front;
        loc = loc+1;
    end
    if Temp ~= 0
        data_areas(:, :, loc) = sum(squeeze(sum(...
            data(:, :, TemporalLoc, TemporalLoc), 3)), idx)/Temp;
        loc = loc+1;
    end
    if Occ ~= 0
        data_areas(:, :, loc) = sum(squeeze(sum(...
            data(:, :, OccipitalLoc, OccipitalLoc), 3)), idx)/Occ;
        loc = loc+1;
    end
    if Par ~= 0
        data_areas(:, :, loc) = sum(squeeze(sum(...
            data(:, :, ParietalLoc, ParietalLoc), 3)), idx)/Par;
        loc = loc+1;
    end
    if Cent ~= 0
        data_areas(:, :, loc) = sum(squeeze(sum(...
            data(:, :, CentralLoc, CentralLoc), 3)), idx)/Cent;
    end
    
    data = data_areas;
    if length(size(data)) == 2 && nEpochs > 1
        for i = 1:nLoc
            ep_plot(squeeze(data(:, i)), nEpochs, measure, strcat(...
                nBands, '_', areas{i}), save_check, format, dataPath)
        end
        return
    end
    for j = 1:length(nBands)
        for i = 1:nLoc
            ep_plot(squeeze(data(j, :, i)), nEpochs, measure, strcat(...
                nBands(j), '_', areas{i}), save_check, format, ...
                dataPath)
        end
    end
end