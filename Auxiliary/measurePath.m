%% measurePath
% This function returns the path to the chosen spatial subdivision of the 
% selected measure, managing the differences between network metrics and
% other measures.
%
% path = measurePath(dataPath, measure, area)
%
% Input:
%   dataPath is the main folder of the study
%   measure is the name of the measure ("measure-network metric" in case of
%       network metrics
%   area is the name of the spatial subdivision
%
% Output:
%   path is the subdirectory related to the spatial subdivision of the
%       selected measure


function path = measurePath(dataPath, measure, area)
    if contains(measure, '-')
        aux_meas = split(measure, '-');
        path = path_check(strcat(path_check(dataPath), ...
            path_check(aux_meas(1)), path_check('Network'), ...
            path_check(aux_meas(end)), area));
    else
        path = path_check(strcat(path_check(dataPath), ...
            path_check(measure), path_check('Epmean'), area));
    end
end