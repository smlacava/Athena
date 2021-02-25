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
        try
        if contains(locations(i, 1), ["pars", "orbito", ...
                "paracentral", "anterior", "temporal", "fusiform", ...
                "ento", "parahippocampal", "lingual", "cuneus", ...
                "pericalcarine", "supramarginal", "postcentral", ...
                "precuneus", "posterior", "isthmus"])
        	deskilFLAG = 1;
            break;
        end
        catch
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
            loc = char(locations{i, 1});
            n = length(loc);
            aux = zeros(1, n);
            ind = 1:n;
            for c = 1:n
                aux(1, c) = str2double(loc(c));
            end
            if sum(not(isnan(aux))) == 0
                continue;
            end
            if mod(str2double(loc(max((isnan(aux)==0).*ind))), 2) == 0
                Right = [Right, i];
            else
                Left = [Left, i];
            end
        end
    end
 end