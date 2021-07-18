%% hemiareas_manager
% This function provides indeces relating to the central area, to the 
% frontal area, to the temporal area, to the occipital and to the parietal 
% area, related to the single hemispheres, in a location column vector.
% 
% [CentralR, FrontalR, TemporalR, OccipitalR, ParietalR, CentralL, ...
%         FrontalL, TemporalL, OccipitalL, ParietalL] = ...
%         hemiareas_manager(locations)
%
% input:
%   locations is a column vector of location names.
%
% output:
%   CentralR is the row vector of the right central area indices
%   FrontalR is the row vector of the right frontal area indices
%   TemporalR is the row vector of the right temporal area indices
%   OccipitalR is the row vector of the right occipital area indices
%   ParietalR is the row vector of the right parietal area indices
%   CentralL is the row vector of the left central area indices
%   FrontalL is the row vector of the left frontal area indices
%   TemporalL is the row vector of the left temporal area indices
%   OccipitalL is the row vector of the left occipital area indices
%   ParietalL is the row vector of the left parietal area indices


function [CentralR, FrontalR, TemporalR, OccipitalR, ParietalR, ...
    CentralL, FrontalL, TemporalL, OccipitalL, ParietalL] = ...
    hemiareas_manager(locations)

    CentralR=[];
    FrontalR=[];
    TemporalR=[];
    OccipitalR=[];
    ParietalR=[];
    CentralL=[];
    FrontalL=[];
    TemporalL=[];
    OccipitalL=[];
    ParietalL=[];
    
    for i = 1:length(locations)
        try
        if contains(locations(i, 1), ["frontal", "pars", "orbito", ...
                "paracentral", "anterior"])
            if contains(locations(i, 1), "R")
                FrontalR = [FrontalR, i];
            else
                FrontalL = [FrontalL, i];
            end
        elseif contains(locations(i, 1), ["temporal", "fusiform", ...
                "ento", "parahippocampal"])
            if contains(locations(i, 1), "R")
                TemporalR = [TemporalR, i];
            else
                TemporalL = [TemporalL, i];
            end
        elseif contains(locations(i, 1), ["occipital", "lingual", ...
                "cuneus", "pericalcarine"])
            if contains(locations(i, 1), "R")
                OccipitalR = [OccipitalR, i];
            else
                OccipitalL = [OccipitalL, i];
            end
        elseif contains(locations(i, 1), ["parietal", "supramarginal", ...
                "postcentral", "precuneus", "posterior", "isthmus"])
            if contains(locations(i, 1), "R")
                ParietalR = [ParietalR, i];
            else
                ParietalL = [ParietalL, i];
            end
        end
        catch
        end
    end
    if isempty(CentralR) && isempty(FrontalR) && isempty(TemporalR) ...
                && isempty(OccipitalR) && isempty(ParietalR)
        for i = 1:length(locations)
            loc = char(locations{i, 1});
            n = length(loc);
            R_cond = 0;
            for c = 1:n
                if not(isnan(str2double(loc(c))))
                    if mod(str2double(loc(c)), 2) == 0
                        R_cond = 1;
                        continue;
                    end
                end
            end
            if contains(loc, "LOC") || contains(loc, "ROC")
                continue;
            end
            if contains(loc, "C")
                if R_cond == 1
                    CentralR = [CentralR, i];
                else
                    CentralL = [CentralL, i];
                end
            end
            if contains(loc, "F") || contains(loc, "A")
                if R_cond == 1
                    FrontalR = [FrontalR, i];
                else
                    FrontalL = [FrontalL, i];
                end
            end
            if contains(loc, "T")
                if R_cond == 1
                    TemporalR = [TemporalR, i];
                else
                    TemporalL = [TemporalL, i];
                end
            end
            if contains(loc, "O")
                if R_cond == 1
                    OccipitalR = [OccipitalR, i];
                else
                    OccipitalL = [OccipitalL, i];
                end
            end
            if contains(loc, "P")
                if R_cond == 1
                    ParietalR = [ParietalR, i];
                else
                    ParietalL = [ParietalL, i];
                end
            end
        end
    end
end