%% meas_man_asy_conn
% This function manages the data matrix to compute the following
% correlation between the asymmetry of two connectivity measures.
% 
% data = meas_man_asy_conn(data_pre, RightLoc, LeftLoc)
%
% input:
%   data_pre is the data matrix to manage
%   RightLoc is an array which contains indexes of the right locations
%   LeftLoc is an array which contains indexes of the left locations
%
% output:
%   data is the managed data matrix

function [data] = meas_man_asy_conn(data_pre, RightLoc, LeftLoc)
    nSub = size(data_pre, 1);
    R = length(RightLoc);
    R = R*R-R;
    L = length(LeftLoc);
    L = L*L-L;

    if length(size(data_pre)) == 4
        nBands = size(data_pre, 2);
        data_asy = zeros(nSub, nBands, 2);
        data_asy(:, :, 1) = sum(squeeze(sum( ...
            data_pre(:, :, RightLoc, RightLoc), 3)), 3)/R;
        data_asy(:, :, 2) = sum(squeeze(sum( ...
            data_pre(:, :, LeftLoc, LeftLoc), 3)), 3)/L;

        data = zeros(nSub, nBands, 1);
        for i = 1:nBands
            data(:, i, 1) = abs(data_asy(:, i, 1)-data_asy(:, i, 2));
        end

    else
        data_asy = zeros(nSub, 2);
        data_asy(:, 1) = sum(squeeze(sum( ...
            data_pre(:, RightLoc, RightLoc), 2)), 2)/R;
        data_asy(:, 2) = sum(squeeze(sum( ...
            data_pre(:, LeftLoc, LeftLoc), 2)), 2)/L;
        data = zeros(nSub, 1, 1);
        data(:, 1, 1) = abs(data_asy(:, 1)-data_asy(:, 2));
    end
end