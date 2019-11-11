%% meas_man_tot
% This function manages the data matrix to compute the following
% correlation in each location between two not-connectivity measures.
% 
% data = meas_man_tot_conn(data_pre, locations)
%
% input:
%   data_pre is the data matrix to manage
%   locations is an array which contains the name of the locations
%
% output:
%   data is the managed data matrix

function [data] = meas_man_tot(data_pre, locations)

    nLoc = length(locations);
    nSub = size(data_pre, 1);

    if length(size(data_pre)) == 3     
        data = data_pre;      
    else
        data = zeros(nSub, 1, nLoc);
        data(:, 1, :) = data_pre;
    end
end