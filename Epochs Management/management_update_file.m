%% management_update_file
% This function is used to update the text file which contains the
% parameters of the study after the spatial and temporal averaging
%
% management_update_file(measurePath, locs, sub)
% 
% input:
%   measurePath is the directory of the study's extracted measure
%   locs is the name of the file (with its path) which contains the list of
%       the locations
%   sub is the name of the file (with its path) which contains the list of
%       the subjects


function management_update_file(measurePath, locs, sub)
    if isempty(locs)
        locs = strcat(measurePath, 'Locations.mat');
    end
    
    update_file(strcat(path_check(measurePath), 'auxiliary.txt'), ...
        {'EpochsAverage=true', strcat('Subjects=', char_check(sub)), ...
        strcat('Locations=', char_check(locs))});
end