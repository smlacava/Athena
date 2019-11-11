%% meas_man_glob_conn
% This function manages the data matrix to compute the following
% correlation between two global connectivity measures.
% 
% data = meas_man_glob_conn(data_pre)
%
% input:
%   data_pre is the data matrix to manage
%
% output:
%   data is the managed data matrix

function [data] = meas_man_glob_conn(data_pre)

    nLoc = size(data_pre, 3);
    nSub = size(data_pre, 1);

    if length(size(data_pre)) == 4    
        nBands = size(data_pre, 2);
        data = zeros(nSub, nBands, 1);
        data(:, :, 1) = squeeze(sum(data_pre, [3 4])/(nLoc*nLoc-nLoc));
    else
        data = zeros(nSub, 1, 1);
        data(:, 1, 1) = sum(data_pre, [2 3])/(nLoc*nLoc-nLoc);
    end
end