%% meas_man_areas_conn
% This function manages the data matrix to compute the following
% correlation between two connectivity measures in the Frontal, Temporal, 
% Central, Parietal and Occipital areas.
% 
% [data, areas] = meas_man_asy_conn(data_pre, FrontalLoc, TemporalLoc, ...
%     OccipitalLoc, ParietalLoc, CentralLoc)
%
% input:
%   data_pre is the data matrix to manage
%   FrontalLoc is an array which contains indexes of the frontal locations
%   TemporalLoc is an array which contains indexes of the temporal 
%       locations
%   OccipitalLoc is an array which contains indexes of the occipital 
%       locations
%   ParietalLoc is an array which contains indexes of the parietal
%       locations
%   CentralLoc is an array which contains indexes of the central locations
%
% output:
%   data is the managed data matrix
%   areas is the list of the areas to correlate

function [data, areas] = meas_man_areas_conn(data_pre, FrontalLoc, ...
    TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc)
    nSub = size(data_pre, 1);

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
    
    if length(size(data_pre)) == 4
        nBands = size(data_pre, 2);
        data = zeros(nSub, nBands, nLoc);
        
        loc = 1;
        if Front ~= 0
            data(:, :, loc) = sum(squeeze(sum( ...
                data_pre(:, :, FrontalLoc), 3)), 3)/Front;
            loc = loc+1;
        end
        if Temp ~= 0
            data(:, :, loc) = sum(squeeze(sum( ...
                data_pre(:, :, TemporalLoc), 3)), 3)/Temp;
            loc = loc+1;
        end
        if Occ ~= 0
            data(:, :, loc) = sum(squeeze(sum( ...
                data_pre(:, :, OccipitalLoc), 3)), 3)/Occ;
            loc = loc+1;
        end
        if Par ~= 0
            data(:, :, loc) = sum(squeeze(sum( ...
                data_pre(:, :, ParietalLoc), 3)), 3)/Par;
            loc = loc+1;
        end
        if Cent ~= 0
            data(:, :, loc) = sum(squeeze(sum( ...
                data_pre(:, :, CentralLoc), 3)), 3)/Cent;
        end
    else
        data = zeros(nSub, 1, nLoc);
        loc = 1;
        if Front ~= 0
            data(:, 1, loc) = sum(squeeze(sum( ...
                data_pre(:, FrontalLoc), 2)), 2)/Front;
            loc = loc+1;
        end
        if Temp ~= 0
            data(:, 1, loc) = sum(squeeze(sum( ...
                data_pre(:, TemporalLoc), 2)), 2)/Temp;
            loc = loc+1;
        end
        if Occ ~= 0
            data(:, 1, loc) = sum(squeeze(sum( ...
                data_pre(:, OccipitalLoc), 2)), 2)/Occ;
            loc = loc+1;
        end
        if Par ~= 0
            data(:, 1, loc) = sum(squeeze(sum( ...
                data_pre(:, ParietalLoc), 2)), 2)/Par;
            loc = loc+1;
        end
        if Cent ~= 0
            data(:, 1, loc) = sum(squeeze(sum( ...
                data_pre(:, CentralLoc), 2)), 2)/Cent;
        end
    end
end