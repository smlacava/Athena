%% hemispheres_conn
% This function computes the average of a connectivity measure in the two
% hemispheres for a subject
%
% [data_areas] = hemispheres_conn(data)
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


function [data_hemispheres] = hemispheres_conn(data)
    [Right, Left] = asymmetry_manager(data.locations);
    R = length(Right);
    L = length(Left);
    data_hemispheres.measure = [];
    data_hemispheres.locations = [];
    count = 1;
    if R ~= 0
        R = R*R-R;
        if length(size(data.measure)) == 4
            data_hemispheres.measure(:, :, count) = ...
                sum(sum(data.measure(:, :, Right, Right), 4), ...
                3)/R;
        else
            data_hemispheres.measure(:, :, count) = ...
                sum(sum(data.measure(:, Right, Right), 3), 2)/R;
        end
        data_hemispheres.locations = "Right";
        count = count+1;
    end
    if L ~= 0
        L = L*L-L;
        if length(size(data.measure)) == 4
            data_hemispheres.measure(:, :, count) = ...
                squeeze(sum(sum(data.measure(:, :, Left, Left), 4), 3)/L);
        else
            data_hemispheres.measure(:, :, count) = ...
                sum(sum(data.measure(:, Left, Left), 3), 2)/L;
        end
        data_hemispheres.locations = [data_hemispheres.locations, "Left"];
    end
end