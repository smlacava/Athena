%% time_frequency_analysis
% This function computes the time-frequency plot of a channel of a signal
% or of the average of the time series related to every location
%
% [tf, times, frequencies, f_ticks, t_ticks, n_steps]  = ...
%         time_frequency_analysis(data, fs, idx_chan, fmin, fmax, tmin, ...
%         tmax, n_steps, cymin, cymax, showFLAG)
%
% Input:
%   data is the signal matrix (channels x time samples)
%   fs is the sampling frequency
%   idx_chan is the index of the channel of which execute the
%       time-frequency analysis, or 0 to compute it on the average of
%       signals
%   fmin is the minimum frequency to show
%   fmax is the maximum frequency to show
%   tmin is the initial instant of time (in seconds) to analyze (0 by
%       default)
%   tmax is the final instant of time (in seconds) to analyze (the instant
%       related to the last sample of the signal by default)
%   n_steps is the number of frequency steps to use between the maximum and 
%       the minimum frequency value (40 by default)
%   cymin is minimum number of wavelet cycles (3 by default)
%   cymax is the maximum number of wavelet cycles (10 by default)
%   showFLAG has to be 1 to show the resulting plot, 0 otherwise (1 by
%       default)
%
% Output:
%   tf is the time-frequency matrix
%   times is the array which contains the time instants related to the
%       analyzed samples
%   frequencies is the array which contains the frequency values analyzed
%   f_ticks is the list of frequency ticks (useful for create external
%       figures related to the time-frequency analysis)
%   t_ticks is the list of time ticks (useful for create external figures
%       related to the time-frequency analysis)
%   n_steps is the number of frequency steps used


function [tf, times, frequencies, f_ticks, t_ticks, n_steps] = ...
    time_frequency_analysis(data, fs, idx_chan, fmin, fmax, tmin, tmax, ...
    n_steps, cymin, cymax, showFLAG)

    if nargin < 6
        tmin = 0;
    end
    if nargin < 7
        tmax = length(data)/fs;
    end
    if nargin < 8
        n_steps = 40;
    end
    if nargin < 9
        cymin = 3;
    end
    if nargin < 10
        cymax = 10;
    end
    if nargin < 11
        showFLAG = 1;
    end
    
    n_tot = [1:size(data, 2)]/fs;
    [~, idxmin] = min(abs(n_tot-tmin));
    [~, idxmax] = min(abs(n_tot-tmax));
    
    bg_color = [1 1 1];
    
    frequencies  = linspace(fmin, fmax, n_steps);
    n_freq = length(frequencies);
    n_samples = size(data(:, idxmin:idxmax), 2);
    times = [0:n_samples-1]/fs;
    tf = zeros(n_freq, n_samples);
    
    waves = 2*(linspace(cymin, cymax, n_freq)./(2*pi*frequencies)).^2;
    wvlt = -2:1/fs:2;
    n_wvlt = length(wvlt);
    half_wvlt = floor(n_wvlt/2)+1;
    nConv = n_samples + n_wvlt - 1;
    
    if idx_chan == 0
        dataF = fft(reshape(squeeze(mean(data(:, idxmin:idxmax), 1)), ...
            1, []), nConv);
    else
        dataF = fft(reshape(data(idx_chan, idxmin:idxmax), 1, []), nConv);
    end
    
    for idx_f=1:length(frequencies)
        first_exp = exp(2*1i*pi*frequencies(idx_f)*wvlt);
        second_exp = exp(-wvlt.^2/waves(idx_f));
        W = fft(first_exp.*second_exp, nConv);
        W = W./max(W);
        conv = ifft(W.*dataF);
        conv = squeeze(reshape(conv(half_wvlt:end-half_wvlt+1), ...
            [n_samples, 1]));
        tf(idx_f, :) = mean(abs(conv), 2);
    end
    
    fig = figure;
    set(fig, 'Color', bg_color, 'MenuBar', 'none', ...
        'Name', 'Time-frequency analysis', 'Visible', 'off', ...
        'NumberTitle', 'off');
    contourf(times, frequencies, tf, n_steps, 'linecolor', 'none');
    
    t_ticks = xticks;
    f_ticks = yticks;
    if not(ismember(fmin, f_ticks))
        f_ticks = [fmin, f_ticks];
    end
    if not(ismember(fmax, f_ticks))
        f_ticks = [f_ticks, fmax];
    end
    yticks(f_ticks);
    
    xlabel('Time [s]')
    ylabel('Frequency [Hz]')
    if showFLAG == 1
        set(fig, 'Visible', 'on')
    else
        close(fig)
    end
end