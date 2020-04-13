%% batch_check_area
% This function is used to check the area's type of the location (Areas,
% Global, Asymmetry, Total)
%
% [area, check] = batch_check_area(location)
%
% input:
%   location is the name of the location
%
% output:
%   area is the name of the area's type of the location
%   check is 1 if area is 'Global' or 'Asymmetry' (0 otherwise)


function [area, check] = batch_check_area(location)
    if sum(strcmpi(location, {'Frontal', 'Temporal', 'Parietal', ...
        'Occipital', 'Central'}))
        check = 0;
        area = 'Areas';
    elseif strcmpi(location, 'global')
        check = 1;
        area = 'Global';
    elseif strcmpi(location, 'asymmetry')
        check = 1;
        area = 'Asymmetry';
    else
        check = 0;
        area = 'Total';
    end
end