%% areas_check
% This function check the selected areas of study in statistical and
% correlation analysis, returning the format used from the toolbox (total,
% areas, asymmetry or global)
%
% areasOUT = areas_check(areasIN)
% 
% input:
%   areasIN represents the selected areas of study in analysis through the
%       guided mode or written on the text file for the batch mode
%
% output:
%   areasOUT represents the areas of study in the format used from the
%       toolbox

function [areasOUT] = areas_check(areasIN)
    if sum(strcmp(areasIN, ["Tot", "TOT", "Total", "total", "TOTAL"]))
        areasOUT='total';
    elseif sum(strcmp(areasIN, ["Areas", "areas", "AREAS"]))
        areasOUT='areas';
    elseif sum(strcmp(areasIN, ["Asymmetry", "asymmetry", "ASYMMETRY", ...
            "ASY", "Asy", "asy"]))
        areasOUT='asymmetry';
    else
        areasOUT='global';
    end
end