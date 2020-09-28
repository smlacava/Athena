%% batch_measurePath
% This function returns the path to the chosen temporally averaged measure, 
% managing the differences between network metrics and other measures.
%
% path = batch_measurePath(dataPath, measure)
%
% Input:
%   dataPath is the main folder of the study
%   measure is the name of the measure ("measure-network metric" in case of
%       network metrics
%
% Output:
%   path is the subdirectory related to the spatial subdivision of the
%       selected measure


function path = batch_measurePath(dataPath, measure)
    if contains(measure, '-')
        aux_meas = split(measure, '-');
        path = path_check(strcat(path_check(dataPath), ...
            path_check(aux_meas(1)), path_check('Network'), ...
            path_check(aux_meas(end))));
    else
        path = path_check(strcat(path_check(dataPath), ...
            path_check(measure), 'Epmean'));
    end
end