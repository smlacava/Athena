%% athena_filter
% This function is used to filter an epoch of the input time series through
% a FIR bandpass filter
%
% smoothdata = athena_filter(data, fs, fmin, fmax)
%
% input:
%   data is the time series to filter
%   fs is the sampling frequency
%   fmin is the lower cut frequency
%   fmax is the higher cut frequency
%
% output:
%   smoothdata is the filtered data

function smoothdata = athena_filter(data, fs, fmin, fmax)
    [locs, frames] = size(data);
    order = 3*fix(fs/fmin);
    coef = fir1(order, [fmin fmax]./(fs/2));
    smoothdata = zeros(locs, frames);
    for i = 1:locs
        smoothdata(i, :) = filtfilt(coef, 1, data(i, :));
    end
end