%% meas_man_areas
% This function manages the data matrix to compute the following
% correlation between two not-connectivity measures in the Frontal, 
% Temporal, Central, Parietal and Occipital areas.
% 
% [data, areas] = meas_man_asy(data_pre, FrontalLoc, TemporalLoc, ...
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

function [data, areas] = meas_man_areas(data_pre, FrontalLoc, ...
    TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc)
    Front = length(FrontalLoc);
    Temp = length(TemporalLoc);
    Occ = length(OccipitalLoc);
    Par = length(ParietalLoc);
    Cent = length(CentralLoc);
    areas = string();
    nLoc = 0;
    nSub = size(data_pre,1);
    
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
    
    if length(size(data_pre)) == 3
        nBands = size(data_pre, 2);
        data = zeros(nSub, nBands, nLoc);
        
        loc = 1;
        if Front ~= 0
            data(:, :, loc) = mean(data_pre(:, :, FrontalLoc), 3);
            loc = loc+1;
        end
        if Temp ~= 0
            data(:, :, loc) = mean(data_pre(:, :, TemporalLoc), 3);
            loc = loc+1;
        end
        if Occ ~= 0
            data(:, :, loc) = mean(data_pre(:, :, OccipitalLoc), 3);
            loc = loc+1;
        end
        if Par ~= 0
            data(:, :, loc) = mean(data_pre(:, :, ParietalLoc), 3);
            loc = loc+1;
        end
        if Cent ~= 0
            data(:, :, loc) = mean(data_pre(:, :, CentralLoc), 3);
        end        

    else  
        data = zeros(nSub, 1, nLoc);
        loc = 1;
        if Front ~= 0
            data(:, 1, loc) = mean(data_pre(:, FrontalLoc), 2);
            loc = loc+1;
        end
        if Temp ~= 0
            data(:, 1, loc) = mean(data_pre(:, TemporalLoc), 2);
            loc = loc+1;
        end
        if Occ ~= 0
            data(:, 1, loc) = mean(data_pre(:, OccipitalLoc), 2);
            loc = loc+1;
        end
        if Par ~= 0
            data(:, 1, loc) = mean(data_pre(:, ParietalLoc), 2);
            loc = loc+1;
        end
        if Cent ~= 0
            data(:, 1, loc) = mean(data_pre(:, CentralLoc), 2);
        end    
    end
end