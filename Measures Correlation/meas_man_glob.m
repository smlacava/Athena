%% meas_man_glob
% This function manages the data matrix to compute the following
% correlation between two global not-connectivity measures.
% 
% data = meas_man_glob(data_pre)
%
% input:
%   data_pre is the data matrix to manage
%
% output:
%   data is the managed data matrix

function [data] = meas_man_glob(data_pre)
    nSub = size(data_pre, 1);

    if length(size(data_pre)) == 3
        nBands = size(data_pre, 2);
        data = zeros(nSub, nBands, 1);
        for i = 1:nBands
            data(:, i, 1) = squeeze(mean(data_pre(:, i, :), 3));
        end

    else
        data = zeros(nSub, 1, 1);
        data(:, 1, 1) = squeeze(mean(data_pre, 2));
    end
end