%% meas_man_asy
% This function manages the data matrix to compute the following
% correlation between the asymmetry of two not-connectivity measures.
% 
% data = meas_man_asy(data_pre, RightLoc, LeftLoc)
%
% input:
%   data_pre is the data matrix to manage
%   RightLoc is an array which contains indexes of the right locations
%   LeftLoc is an array which contains indexes of the left locations
%
% output:
%   data is the managed data matrix

function [data] = meas_man_asy(data_pre, RightLoc, LeftLoc)
    nSub = size(data_pre, 1);

    if length(size(data_pre)) == 3
        nBands = size(data_pre, 2);
        data_asy = zeros(nSub, nBands, 2);
        data_asy(:, :, 1) = mean(data_pre(:, :, RightLoc), 3);
        data_asy(:, :, 2) = mean(data_pre(:, :, LeftLoc), 3);

        data = zeros(nSub, nBands);
        for i = 1:nBands
            data(:, i) = abs(data_asy(:, i, 1)-data_asy(:, i, 2));
        end

    else
        data_asy = zeros(nSub, 2);
        data_asy(:, 1) = mean(data_pre(:, RightLoc), 2);
        data_asy(:, 2) = mean(data_pre(:, LeftLoc), 2);
        
        data = zeros(nSub, 1, 1);
        data(:, 1, 1) = abs(data_asy(:, 1)-data_asy(:, 2));
    end
end