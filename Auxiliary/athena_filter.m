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
    if fmin == 0 & fmax >= fs/2
        smoothdata = data;
    else
        [locs, frames] = size(data);
        fmax = min(fs/2, fmax);
        if fmin > 0
            order = max(3*fix(fs/fmin), 15);
        else
            order = max(3*fix(fs/fmax), 15);
        end
        if fmin > 0 & fmax > 0
            coef = fir1(order, [fmin fmax]./(fs/2));
        elseif fmin > 0
            coef = fir1(order, fmin./(fs/2), 'high');
        elseif fmax > 0
            coef = fir1(order, fmax./(fs/2));
        end
        smoothdata = zeros(locs, frames);
        for i = 1:locs
            smoothdata(i, :) = filtfilt(coef, 1, double(data(i, :)));
        end
    end
end