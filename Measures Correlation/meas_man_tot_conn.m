%% meas_man_tot_conn
% This function manages the data matrix to compute the following
% correlation in each location between two connectivity measures.
% 
% data = meas_man_tot_conn(data_pre, locations)
%
% input:
%   data_pre is the data matrix to manage
%   locations is an array which contains the name of the locations
%
% output:
%   data is the managed data matrix

function [data] = meas_man_tot_conn(data_pre, locations)

    nLoc = length(locations);
    nSub = size(data_pre, 1);

    if length(size(data_pre)) == 4    
        nBands = size(data_pre, 2);
        data = zeros(size(data_pre, 1), nBands, nLoc);
        for i = 1:nBands
            for j = 1:nLoc
                data(:, i, j) = sum(data_pre(:, i, j, :), 4)/(nLoc-1);
            end
        end    
    else
        data = zeros(nSub, 1, nLoc);
        for i = 1:nLoc
            data(:, 1, i) = sum(data_pre(:, i, :), 3)/(nLoc-1);
        end
    end
end