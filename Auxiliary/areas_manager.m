%% areas_manager
% This function provides indeces relating to the central area, to the 
% frontal area, to the temporal area, to the occipital and to the parietal 
% area relative in a location column vector.
% 
% [Central, Frontal, Temporal, Occipital, Parietal]=areas_manager(locations)
%
% input:
%   locations is a column vector of location names.
%
% output:
%   Central is the row vector of the central area indices
%   Frontal is the row vector of the frontal area indices
%   Temporal is the row vector of the temporal area indices
%   Occipital is the row vector of the occipital area indices
%   Parietal is the row vector of the parietal area indices

function [Central, Frontal, Temporal, Occipital, Parietal]=areas_manager(locations)
    Central=[];
    Frontal=[];
    Temporal=[];
    Occipital=[];
    Parietal=[];
    
    for i=1:length(locations)
        if contains(locations(i,1),["frontal", "pars", "orbito", ...
                "paracentral", "anterior"])
        	Frontal=[Frontal, i];
        elseif contains(locations(i,1),["temporal", "fusiform", "ento"...
                            "parahippocampal"])
        	Temporal=[Temporal, i];
        elseif contains(locations(i,1),["occipital", "lingual", ...
                            "cuneus", "pericalcarine"])
        	Occipital=[Occipital, i];
        elseif contains(locations(i,1),["parietal", "supramarginal", ...
                "postcentral", "precuneus", "posterior", "isthmus"])
        	Parietal=[Parietal, i];
        end
    end
    if isempty(Central) && isempty(Frontal) && isempty(Temporal) ...
                && isempty(Occipital) && isempty(Parietal)
        for i=1:length(locations)
            if contains(locations(i,1),"C")
                Central=[Central, i];
            elseif contains(locations(i,1),"F")
                Frontal=[Frontal, i];
            elseif contains(locations(i,1),"A")
                Frontal=[Frontal, i];
            elseif contains(locations(i,1),"T")
                Temporal=[Temporal, i];
            elseif contains(locations(i,1),"O")
                Occipital=[Occipital, i];
            elseif contains(locations(i,1),"P")
                Parietal=[Parietal, i];
            end
        end
    end
 end
     