%% Athena_measure_path_management
% This function returns the measure path.
%
% Input:
%   dataPath is the main directory of the study
%   measure is the name of the measure
%
% Output:
%   dataPath is the managed dataPath

function dataPath = Athena_measure_path_management(dataPath, measure)
    if contains(measure, '-')
         aux_meas = split(measure, '-');
         dataPath = strcat(path_check(dataPath), ...
             path_check(aux_meas(1)), path_check('Network'), ...
             path_check(aux_meas(end)));
    else
         dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    end
end