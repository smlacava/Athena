%% total_conn_av
% This function computes the value of a connectivity measure for each
% location and each frequency band of a subject
%
% [data_total] = total_conn_av(data)
%
% input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% output:
%   data_total is the resulting structure, which contains the averaged 
%       value for each frequency band and the list of the locations


function [data_total] = total_conn_av(data)
    if not(isempty(data.measure)) 
        nLoc = size(data.measure, 2);
        n = length(size(data.measure));
        data_total.measure = squeeze(sum(data.measure, n));
        data_total.measure = data_total.measure/(nLoc-1);
        data_total.locations = data.locations;
    end
end