%% resample_signal
% This function resamples a time series.
%
% time_series = resample_signal(time_series, fs, fs_old)
%
% Input:
%   time_series is the (locations x samples) time series which has to be
%       resampled
%   fs is the new sample frequency
%   fs_old is the current sample frequency
%
% Output:
%   time_series is the resamples time series


function time_series = resample_signal(time_series, fs, fs_old)
    if nargin < 3
        fs_old = fs;
    end
    
    if isempty(fs_old)
        fs_old = fs;
    end
    if fs_old ~= fs
        [p, q] = rat(fs/fs_old);
        time_series = resample(time_series', p, q)';
    end
end