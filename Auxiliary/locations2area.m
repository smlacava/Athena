%% locations2area
% This function returns the area related to the list of locations (Global,
% Channels, Hemispheres, Areas or Hemi-Areas).
%
% locs = locations2area(locs)
%
% Input:
%   locs is the cell array containing the list of locations
%
% Output:
%   locs is the area related to the input locations


function locs = locations2area(locs)
    areas = 0;
    hemispheres = 0;
    if sum(contains(locs, {'Frontal', 'Parietal', 'Occipital', ...
            'Central', 'Temporal'})) > 1
        areas = 1;
    elseif sum(contains(locs, {'Right', 'Left'})) > 1
        hemispheres = 1;
    end
    
    if areas == 1 && hemispheres == 1
        locs = 'Hemi-Areas';
    elseif areas == 1
        locs = 'Areas';
    elseif hemispheres == 1
        locs = 'Hemispheres';
    elseif not(contains(locs, 'Asymmetry')) && ...
            not(contains(locs, 'Global'))
        locs = 'Channels';
    end
end