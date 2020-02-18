%% global_conn_av
% This function computes the global average of a connectivity measure for
% each frequency band of a subject
%
% [data_areas] = global_conn_av(data)
%
% input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% output:
%   data_global is the resulting structure, which contains the globally
%       averaged value for each frequency band and the locations field set
%       as "global"


function [data_global] = global_conn_av(data)
    if not(isempty(data.measure)) 
        nLoc = size(data.measure, 2);
        n = length(size(data.measure));
        data_global.measure = squeeze(sum(data.measure, [n-1, n]));
        data_global.measure = data_global.measure/(nLoc*nLoc-nLoc);
        data_global.locations = "global";
    end
end