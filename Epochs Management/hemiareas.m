%% hemiareas
% This function computes the average of a non-connectivity measure for a
% subject in the Frontal area, in the Temporal area, in the Occipital area,
% in the Parietal area and in the Central area, in the single hemispheres.
%
% [data_areas] = hemiareas(data)
%
% Input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% Output:
%   data_hemiareas is the resulting structure, which contains the averaged
%       data and the list of the resulting areas


function [data_hemiareas] = hemiareas(data)
    [CentralR, FrontalR, TemporalR, OccipitalR, ParietalR, CentralL, ...
        FrontalL, TemporalL, OccipitalL, ParietalL] = ...
        hemiareas_manager(data.locations);
    FrontR = length(FrontalR);
    TempR = length(TemporalR);
    OccR = length(OccipitalR);
    ParR = length(ParietalR);
    CentR = length(CentralR);
    FrontL = length(FrontalL);
    TempL = length(TemporalL);
    OccL = length(OccipitalL);
    ParL = length(ParietalL);
    CentL = length(CentralL);
    
    indexes = {};
    areas = string();
    nLoc = 0;
    if FrontR ~= 0
        nLoc = nLoc+1;
        areas = [areas, "RightFrontal"];
        indexes = [indexes, FrontalR];
    end
    if TempR ~= 0
        nLoc = nLoc+1;
        areas = [areas, "RightTemporal"];
        indexes = [indexes, TemporalR];
    end
    if OccR ~= 0
        nLoc = nLoc+1;
        areas = [areas, "RightOccipital"];
        indexes = [indexes, OccipitalR];
    end
    if ParR ~= 0
        nLoc = nLoc+1;
        areas = [areas, "RightParietal"];
        indexes = [indexes, ParietalR];
    end
    if CentR ~= 0
        nLoc = nLoc+1;
        areas = [areas, "RightCentral"];
        indexes = [indexes, CentralR];
    end
    if FrontL ~= 0
        nLoc = nLoc+1;
        areas = [areas, "LeftFrontal"];
        indexes = [indexes, FrontalL];
    end
    if TempL ~= 0
        nLoc = nLoc+1;
        areas = [areas, "LeftTemporal"];
        indexes = [indexes, TemporalL];
    end
    if OccL ~= 0
        nLoc = nLoc+1;
        areas = [areas, "LeftOccipital"];
        indexes = [indexes, OccipitalL];
    end
    if ParL ~= 0
        nLoc = nLoc+1;
        areas = [areas, "LeftParietal"];
        indexes = [indexes, ParietalL];
    end
    if CentL ~= 0
        nLoc = nLoc+1;
        areas = [areas, "LeftCentral"];
        indexes = [indexes, CentralL];
    end
    areas(1) = [];
    
    if length(size(data.measure)) == 3
        data_hemiareas.measure = zeros(size(data.measure, 1), ...
            size(data.measure, 2), nLoc);
        for i = 1:nLoc
            data_hemiareas.measure(:, :, i) = ...
                squeeze(mean(data.measure(:, :, indexes{i}), 3));
        end
    else
        data_hemiareas.measure = zeros(size(data.measure, 1),  nLoc);
        for i = 1:nLoc
            data_hemiareas.measure(:, i) = ...
                squeeze(mean(data.measure(:, indexes{i}), 2));
        end
    end
    data_hemiareas.locations = areas;
end
    