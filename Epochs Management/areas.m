%% areas
% This function computes the average of a non-connectivity measure for a
% subject in the Frontal area, in the Temporal area, in the Occipital area,
% in the Parietal area and in the Central area
%
% [data_areas] = areas(data)
%
% input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% output:
%   data_areas is the resulting structure, which contains the averaged data
%       and the list of the resulting areas


function [data_areas] = areas(data)
    [Central, Frontal, Temporal, Occipital, Parietal] = ....
        areas_manager(data.locations);
    Front = length(Frontal);
    Temp = length(Temporal);
    Occ = length(Occipital);
    Par = length(Parietal);
    Cent = length(Central);
    indexes = {};
    areas = string();
    nLoc = 0;
    if Front ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Frontal"];
        indexes = [indexes, Frontal];
    end
    if Temp ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Temporal"];
        indexes = [indexes, Temporal];
    end
    if Occ ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Occipital"];
        indexes = [indexes, Occipital];
    end
    if Par ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Parietal"];
        indexes = [indexes, Parietal];
    end
    if Cent ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Central"];
        indexes = [indexes, Central];
    end
    areas(1) = [];
        
    if length(size(data.measure)) == 3
        data_areas.measure = zeros(size(data.measure, 1), ...
            size(data.measure, 2), nLoc);
        for i = 1:nLoc
            data_areas.measure(:, :, i) = ...
                squeeze(mean(data.measure(:, :, indexes{i}), 3));
        end
    else
        data_areas.measure = zeros(size(data.measure, 1), nLoc);
        for i = 1:nLoc
            data_areas.measure(:, i) = ...
                squeeze(mean(data.measure(:, indexes{i}), 2));
        end
    end
    data_areas.locations = areas;
end
    