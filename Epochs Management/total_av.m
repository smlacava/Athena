%% total_av
% This function computes the value of a non-connectivity measure for each
% location and each frequency band of a subject
%
% [data_total] = total_av(data)
%
% input:
%   data is the input structure which contains the measure for each 
%       frequency band and for each location
%   
% output:
%   data_total is the resulting structure, which contains the averaged 
%       value for each frequency band and the list of the locations


function [data_total] = total_av(data)
    if not(isempty(data.measure)) 
        data_total.measure = data.measure;
        data_total.locations = data.locations;
    end
end