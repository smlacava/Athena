%% spatial_subdivision
% This function returns the spatial subdivision related to a set of
% locations.
%
% area = spatial_subdivision(areas)
%
% Input:
%   areas is the cell array representing the set of locations
%
% Output:
%   area is string representing the spatial subdivision, among Global, 
%       Asymmetry, Total and Areas (empty if areas is an empty vector)


function area = spatial_subdivision(areas)
    area = [];
    if length(areas) == 1
        if strcmpi(areas, "Global")
            area = "Global";
        elseif strcmpi(areas, "Asymmetry")
            area = "Asymmetry";
        end
    elseif strcmpi(areas{1}, "Central") || ...
            strcmpi(areas{1}, "Temporal") || ...
            strcmpi(areas{1}, "Parietal") || ...
            strcmpi(areas{1}, "Occipital") || strcmpi(areas{1}, "Frontal")
        area = "Areas";
    elseif not(isempty(areas))
        area = "Total";
    end
end