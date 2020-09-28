%% Athena_bands_management
% This function returns the list of frequency bands, in which each element
% has format "lower-upper Hz", automatically managing the differences
% between background measures, network measures and other measures.
%
% bands = Athena_bands_management(dataPath, measure, data)
%
% Input:
%   dataPath is the main directory of the study
%   measure is the name of the measure ("measure-network metric" in case of
%       network metrics
%   data is the data structure related to a subject
%
% Output:
%   bands is the list of frequency bands


function bands = Athena_bands_management(dataPath, measure, data)
    if contains(dataPath, 'Epmean')
        if strcmpi(measure, 'Offset') || strcmpi(measure, 'Exponent')
            bands = define_bands(limit_path(dataPath, 'Epmean'), ...
                size(data.measure, 1), 1);
        else
            bands = define_bands(limit_path(dataPath, 'Epmean'), ...
                size(data.measure, 1));
        end
    else
        bands = define_bands(limit_path(dataPath, 'Network'), ...
            size(data.measure, 1));
    end
end