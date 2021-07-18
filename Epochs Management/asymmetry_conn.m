%% asymmetry_conn
% This function computes the asymmetry of a connectivity measure for a
% subject and the resulting values are the differences between the right
% locations and the left locations (so, a positive value means an increased
% mean value of the measure in right locations respect to left locations,
% while a negative value means the opposite)
%
% [data_areas] = asymmetry_conn(data)
%
% input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% output:
%   data_asymmetry is the resulting structure, which contains the asymmetry
%       value for each frequency band and the locations field set as 
%       "asymmetry" (void measure and locations in case of the absence of
%       the right locations or of the left locations)


function [data_asymmetry] = asymmetry_conn(data)
    [Right, Left] = asymmetry_manager(data.locations);
    R = length(Right);
    L = length(Left);
    if R ~= 0 && L ~= 0
        R = R*R-R;
        L = L*L-L;
        if length(size(data.measure)) == 4
            r_meas = sum((sum(data.measure(:, :, Right, Right), ...
                4)), 3)/R;
            l_meas = sum((sum(data.measure(:, :, Left, Left), ...
                4)), 3)/L;
        else
            r_meas = sum(sum(data.measure(:, Right, Right), 2), 2)/R;
            l_meas = sum(sum(data.measure(:, Left, Left), 2), 2)/L;
        end
        data_asymmetry.measure = abs(squeeze(r_meas-l_meas));
        data_asymmetry.locations = "asymmetry";
    else
        data_asymmetry.measure = [];
        data_asymmetry.locations = [];
    end
end