%% hemispheres
% This function computes the average of a non-connectivity measure on the
% single hemisphere for a subject.
%
% [data_areas] = hemispheres(data)
%
% Input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% Output:
%   data_hemispheres is the resulting structure, which contains values of
%       the right hemisphere and the left one, for each frequency band, and 
%       the locations field set as ["Right", "Left"] (or only one of them, 
%       or even empty, and  locations in case of the absence of the right 
%       locations, of the left locations or both)


function [data_hemispheres] = hemispheres(data)
    [Right, Left] = asymmetry_manager(data.locations);
    data_hemispheres.measure = [];
    data_hemispheres.locations = [];
    count = 1;
    if length(size(data.measure)) == 3
        if not(isempty(Right))
            data_hemispheres.measure(:, :, count) = ...
                mean(data.measure(:, :, Right), 3);
            data_hemispheres.locations = "Right";
            count = count+1;
        end
        if not(isempty(Left))
            data_hemispheres.measure(:, :, count) = ...
                mean(data.measure(:, :, Left), 3);
            data_hemispheres.locations = [data_hemispheres.locations, "Left"];
        end
    else
        if not(isempty(Right))
            data_hemispheres.measure(:, count) = ...
                mean(data.measure(:, Right), 2);
            data_hemispheres.locations = "Right";
            count = count+1;
        end
        if not(isempty(Left))
            data_hemispheres.measure(:, count) = ...
                mean(data.measure(:, Left), 2);
            data_hemispheres.locations = [data_hemispheres.locations, "Left"];
        end
    end
end
