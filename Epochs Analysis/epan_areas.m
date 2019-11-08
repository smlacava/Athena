%% epan_areas
% This function computes the epochs analysis of a previously extracted 
% not-connectivity measure of a subject in frontal, temporal, central,
% occipital and parietal areas.
%
% epan_areas(data, nEpochs, nBands, measure, name, CentralLoc, ...
%       FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc)
%
% input:
%   data is the measure matrix
%   nEpochs is the number of epochs
%   nBands is the number of frequency bands
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

function epan_areas(data, nEpochs, nBands, measure, name, CentralLoc, ...
    FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc)
    
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
    if length(dim) == 2
        aux = zeros(1, dim(1), dim(2));
        aux(1, :, :) = data;
        data = aux;
    end
    
    loc = 1;
    if Front ~= 0
    	data_areas(:, :, loc) = mean(data(:, :, FrontalLoc), 3);
        loc = loc+1;
    end
    if Temp ~= 0
        data_areas(:, :, loc) = mean(data(:, :, TemporalLoc), 3);
        loc = loc+1;
    end
    if Occ ~= 0
        data_areas(:, :, loc) = mean(data(:, :, OccipitalLoc), 3);
        loc = loc+1;
    end
    if Par ~= 0
        data_areas(:, :, loc) = mean(data(:, :, ParietalLoc), 3);
        loc = loc+1;
    end
    if Cent ~= 0
        data_areas(:, :, loc) = mean(data(:, :, CentralLoc), 3);
    end
    
    for i = 1:length(areas)
        ep_scatter(data_areas(:, :, i), nEpochs, nBands, ...
            strcat(char_check(name), ' ', char_check(areas(i))), ...
            measure)
    end