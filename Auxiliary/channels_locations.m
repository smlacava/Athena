%% channels_locations
% This function assigns the coordinates to each channel contained in a
% structure, represented in a cartesian, polar or spherical way, starting
% from another already present representation.
%
% chanlocs = channels_locations(chanlocs, coordinates)
%
% Input:
%   chanlocs is the structure containing information about the channels,
%       providing at least a labels field related to each channel's name,
%       and a set of fields containing the coordinates in a cartesian (X
%       and Y), spherical (sph_theta, sph_radius and sph_phi) or polar 
%       (theta and radius) representation
%   coordinates it the type of representation which has to be obtained,
%       among polar ('pol'), cartesian ('cart', or 'xyz'), spherical
%       ('sph'), or all the representations ('all', by default)
%
% Output:
%   chanlocs is the structure containing information about the channels,
%       providing a labels field related to each channel's name, and the 
%       sets of fields related to the old and the new representations of 
%       the coordinates for each channel


function chanlocs = channels_locations(chanlocs, coordinates)
    if nargin < 2
        coordinates = 'all';
    end
    
    if strcmpi(coordinates, 'pol')
        chanlocs = pol_locations(chanlocs);
    elseif strcmpi(coordinates, 'cart') | strcmpi(coordinates, 'xyz')
        chanlocs = cart_locations(chanlocs);
    elseif strcmpi(coordinates, 'sph')
        chanlocs = sph_locations(chanlocs);
    else
        chanlocs = cart_locations(chanlocs);
        chanlocs = sph_locations(chanlocs);
        chanlocs = pol_locations(chanlocs);
    end
end


%% pol_locations
% This function computes the coordinates in a polar representation.

function chanlocs = pol_locations(chanlocs)
    if not(isfield(chanlocs, 'theta')) | not(isfield(chanlocs, 'radius'))
        if isfield(chanlocs, 'sph_theta') & isfield(chanlocs, 'sph_phi')
            for i = 1:length(chanlocs)
                chanlocs(i).radius = 0.5 - chanlocs(i).sph_phi/180;
                chanlocs(i).theta = -chanlocs(i).sph_theta;
            end
        elseif isfield(chanlocs, 'X') & isfield(chanlocs, 'Y') & ...
                isfield(chanlocs, 'Z')
            for i = 1:length(chanlocs)
                [sph_theta, sph_phi, ~] = cart2sph(chanlocs(i).X, ...
                    chanlocs(i).Y, chanlocs(i).Z);
                sph_phi = rad2deg(sph_phi);
                sph_theta = rad2deg(sph_theta);
                chanlocs(i).radius = 0.5 - sph_phi/180;
                chanlocs(i).theta = -sph_theta;
            end
        end
    end
end


%% cart_locations
% This function computes the coordinates in a cartesian representation.

function chanlocs = cart_locations(chanlocs)
    if not(isfield(chanlocs, 'X')) | not(isfield(chanlocs, 'Y')) | ...
            not(isfield(chanlocs, 'Z'))
        if isfield(chanlocs, 'sph_theta') & ...
                isfield(chanlocs, 'sph_phi') & ...
                isfield(chanlocs, 'sph_radius')
            for i = 1:length(chanlocs)
                [chanlocs(i).X, chanlocs(i).Y, chanlocs(i).Z] = ...
                    sph2cart(deg2rad(chanlocs(i).sph_theta), ...
                    deg2rad(chanlocs(i).sph_phi), chanlocs(i).sph_radius);
            end
        end
    end
end


%% sph_locations
% This function computes the coordinates in a spherical representation.

function chanlocs = sph_locations(chanlocs)
    if not(isfield(chanlocs, 'sph_theta')) | ...
            not(isfield(chanlocs, 'sph_phi')) | ...
            not(isfield(chanlocs, 'sph_radius'))
        if isfield(chanlocs, 'X') & ...
                isfield(chanlocs, 'Y') & ...
                isfield(chanlocs, 'Z')
            for i = 1:length(chanlocs)
                [sph_theta, sph_phi, chanlocs(i).sph_radius] = ...
                    cart2sph(chanlocs(i).X, chanlocs(i).Y, chanlocs(i).Z);
                chanlocs(i).sph_theta = rad2deg(sph_theta);
                chanlocs(i).sph_phi = rad2deg(sph_phi);
            end
        end
    end
end