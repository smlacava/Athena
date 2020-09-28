%% batch_define_bands
% This function is used in batch mode in order to define the list of
% frequency bands analyzed in a single measure.
%
% band_name = batch_define_bands(parameters, measure)
%
% Input:
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study
%   measure is the name of the analyzed measure
%
% Output:
%   band_name is the cell array which contains the name of the frequency
%       bands


function band_name = batch_define_bands(parameters, measure)
    dataPath = search_parameter(parameters, 'dataPath');
    band_name = search_parameter(parameters, 'frequency_bands');
    band_name = define_bands(batch_measurePath(dataPath, measure), ...
        length(band_name));
end