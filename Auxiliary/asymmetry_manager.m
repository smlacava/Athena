%% asymmetry_manager
% This function provides indeces relating to the right area and the left
% area in a location column vector.
% 
% [Right, Left] = asymmetry_manager(locations)
%
% input:
%   locations is a column vector of location names.
%
% output:
%   Right is the row vector of the right area indices
%   Left is the row vector of the left area indices


function [Right, Left] = asymmetry_manager(locations)
    deskilFLAG = 0;
    Left = [];
    Right = [];
    for i = 1:length(locations)
        if contains(locations(i, 1), ["pars", "orbito", ...
                "paracentral", "anterior", "temporal", "fusiform", ...
                "ento", "parahippocampal", "lingual", "cuneus", ...
                "pericalcarine", "supramarginal", "postcentral", ...
                "precuneus", "posterior", "isthmus"])
        	deskilFLAG = 1;
            break;
        end
    end
    if deskilFLAG == 1
        for i = 1:length(locations)
            loc = locations{i, 1};
            if strcmp(loc(end), "R")
                Right = [Right, i];
            else
            	Left = [Left, i];
            end
        end
    else
        for i = 1:length(locations)
            loc = locations{i, 1};
            if not(strcmp(loc(end), "Z"))
                if mod(str2double(loc(end)), 2) == 0
                    Right = [Right, i];
                else
                    Left = [Left, i];
                end
            end
        end
    end
 end