%% time_frequency_analysis
% This function computes the time-frequency plot of a channel of a signal
% or of the average of the time series related to every location, by using
% variable number of wavelet cycles in order to mediate between temporal
% and frequency precision (using the algorithm proposed by Cohen, 2018: A 
% better way to define and describe Morlet wavelets for time-frequency 
% analysis).
%
% [tf, times, frequencies, f_ticks, t_ticks, n_steps]  = ...
%         time_frequency_analysis(data, fs, idx_chan, fmin, fmax, tmin, ...
%         tmax, n_steps, cymin, cymax, scaleFLAG, showFLAG)
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
%       default and if an empty vector is assigned as its value)
%   tmax is the final instant of time (in seconds) to analyze (the instant
%       related to the last sample of the signal by default and if an empty 
%       vector is assigned as its value)
%   n_steps is the number of frequency steps to use between the maximum and 
%       the minimum frequency value (40 by default and if an empty vector 
%       is assigned as its value)
%   cymin is minimum number of wavelet cycles (3 by default and if an empty 
%       vector is assigned as its value)
%   cymax is the maximum number of wavelet cycles (10 by default and if an 
%       empty vector is assigned as its value)
%   scaleFLAG can be 'linear' to use a linear frequency scaling or
%       'log' to use a logaritmic one ('linear' by default)
%   showFLAG has to be 1 to show the resulting plot, 0 or empty vector 
%       otherwise (1 by default)
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
    n_steps, cymin, cymax, scaleFLAG, showFLAG)

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
        scaleFLAG = 'linear';
    end
    if nargin < 12
        showFLAG = 1;
    end
    
    [tmin, tmax, n_steps, cymin, cymax, scaleFLAG, showFLAG] = ...
        parameters_estimation(data, fs, tmin, tmax, n_steps, cymin, ...
        cymax, scaleFLAG, showFLAG);
    bg_color = [1 1 1];

    n_tot = [1:size(data, 2)]/fs;
    [~, idxmin] = min(abs(n_tot-tmin));
    [~, idxmax] = min(abs(n_tot-tmax));
    %if idxmin == 1 && fs ~= 1
    %    idxmax = idxmax+1;
    %end
        
    n_samples = size(data(:, idxmin:idxmax), 2);
    times = [0:n_samples-1]/fs;
    tf = zeros(n_steps, n_samples);
    
    if strcmpi(scaleFLAG, 'linear')
        frequencies  = linspace(fmin, fmax, n_steps);
        waves = 2*(linspace(cymin, cymax, n_steps)./(2*pi*frequencies)).^2;
    elseif strcmpi(scaleFLAG, 'log')
        frequencies = logspace(log10(fmin), log10(fmax), n_steps);
        waves = 2*(logspace(log10(cymin), log10(cymax), n_steps)./...
            (2*pi*frequencies)).^2;
    else 
        return;
    end
    
    t_wv = -2:1/fs:2;
    n_wv = length(t_wv);
    half_wvlt = floor(n_wv/2)+1;
    nConv = n_samples + n_wv - 1;
    
    if idx_chan == 0
        dataF = fft(reshape(squeeze(mean(data(:, idxmin:idxmax), 1)), ...
            1, []), nConv);
    else
        dataF = fft(reshape(data(idx_chan, idxmin:idxmax), 1, []), nConv);
    end
    
    for idx_f = 1:n_steps
        freq = frequencies(idx_f);
        cycles = waves(idx_f);
        mor_wave = exp(2*1i*pi*freq*t_wv).*exp(-t_wv.^2/cycles);
        W = fft(mor_wave, nConv);
        W = W./max(W);
        conv = ifft(W.*dataF, nConv);
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
    fig.Children.YScale = scaleFLAG;
    if showFLAG == 1
        set(fig, 'Visible', 'on')
    else
        close(fig)
    end
end


%% parameters_estimation
% This function assigs their default values when they are inserted as empty
% vectors.

function [tmin, tmax, n_steps, cymin, cymax, scaleFLAG, showFLAG] = ...
    parameters_estimation(data, fs, tmin, tmax, n_steps, cymin, cymax, ...
    scaleFLAG, showFLAG)
    
    if isempty(tmin)
        tmin = 0;
    end
    if isempty(tmax)
        tmax = length(data)/fs;
    end
    if isempty(n_steps)
        n_steps = 40;
    end
    if isempty(cymin)
        cymin = 3;
    end
    if isempty(cymax)
        cymax = 10;
    end
    if isempty(showFLAG)
        showFLAG = 1;
    end
    if isempty(scaleFLAG)
        scaleFLAG = 'linear';
    end
end