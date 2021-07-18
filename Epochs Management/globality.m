%% globality
% This function computes the global average of a non-connectivity measure 
% for each frequency band of a subject
%
% [data_areas] = globality(data)
%
% input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% output:
%   data_global is the resulting structure, which contains the globally
%       averaged value for each frequency band and the locations field set
%       as "global"


function [data_global] = globality(data)
    data_global = data;
    idx = length(size(data.measure));
    try
        if not(isempty(data.measure))
            data_global.measure = squeeze(mean(data.measure, idx));
            data_global.locations = "global";
        end
    catch
    end
end