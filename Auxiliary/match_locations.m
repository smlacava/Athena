%% match_locations
% This function return the indexes which match with the setup locations and
% the indexes to delete from setup locations because they don't match with
% any location of the new subject
% 
% [ind, del_ind] = match_locations(setup_loc, loc)
% 
% input:
%   setup_loc is the array of strings relative to currently considered 
%       locations
%   loc is the array of strings relative to the locations to match
%
% output:
%   ind is the list of indexes which are needed to match the new locations
%       in the right order
%   del_ind is the list of indexes of the locations to delete from the
%       setup locations


function [ind, del_ind] = match_locations(setup_loc, loc)
    nloc = length(loc);
    nsetup = length(setup_loc);
    del_ind = 1:nsetup;
    aux_ind = [];
    ind = [];
    for i = 1:nsetup
        for j = 1:nloc
            if contains(setup_loc{i}, loc{j}) || ...
                    contains(loc{j}, setup_loc{i})
                aux_ind = [aux_ind, i];
                ind = [ind, j];
                break;
            end
        end
    end
    del_ind(aux_ind) = [];   
end

