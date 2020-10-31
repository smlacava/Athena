%% classify_command
% This function records and classify a speech command (down, go, left, no, 
% right, stop, up, yes, zero are currently recognized).
%
% recorded_command = classify_command(record, trainedNet, fs, duration)
%
% Input:
%   record is the array containing the audio samples
%   trainedNet is the trained deep neural network which has to be used to
%       classify the audio signal (commandNet by default, based on the 
%       TensorFlow Speech Recognition Dataset)
%   fs is the sampling frequency which has to be used to record the audio
%   duration is the duration of the recording segment to evaluate (the
%       recording will have the double duration, then the voice segment
%       will be extracted from the longer recording)
%
% Output:
%   recorded_command is the recognized command

function recorded_command = classify_command(record, trainedNet, fs, ...
    duration)
    if nargin < 2
        load('commandNet.mat');
    end
    if nargin < 3
        fs = 16e3;
    end
    if nargin < 4
        duration = 1;
    end
    
    if ischar(trainedNet)
        load(trainedNet);
    end
    
    epsil = 1e-6;
    nHops = 196;
    
    record = find_boundaries(record, fs, duration);
    
    spec = compute_spectrogram(record, fs);
    w = size(spec, 2);
    left = floor((nHops-w)/2)+1;
    ind = left:left+w-1;
    if ind(1) == 0
        spec(:, end) = [];
    end
    spec = log10(spec+epsil);
    [YPredicted, probs] = classify(trainedNet, spec, ...
        'ExecutionEnvironment', 'cpu');
    maxProb = max(probs);
    probThreshold = 0.7;
    if YPredicted == "background" || maxProb < probThreshold
        recorded_command = "background";
    else
        recorded_command = string(YPredicted);
    end
end


%% find_boundaries
% This function finds the voice time boundaries, extracting a part of audio
% signal which contains the voice-related signal (if it is longer than a
% second, then it will be cut).
%
% sample = find_boundaries(sample, fs, final_length)
% 
% Input:
%   sample is the (samples x 1) double array which represents the audio
%       signal
%   fs is the sampling frequency which has been used to record the audio
%       signal
%   final_length is the number of seconds of signal which have to be
%       extracted
%
% Output:
%   sample is the (samples x 1) double array which represents the extracted
%       audio signal

function sample = find_boundaries(sample, fs, final_length)
    aux_sample = sample;
    L = length(sample);
    window = floor(fs/50);
    boundaries = zeros(L, 1);
    final_length = final_length*fs;
    for i = 1:L-window
        aux_sample(i) = mean(abs(sample(i:i+window)));
    end
    aux_sample(end-window+1:end) = [];
    thr = 0.1*max(aux_sample);
    for i = 1:L-window
        if aux_sample(i) > thr
            boundaries(i) = 1;
        end
    end
    idx = find(boundaries == 1);
    min_idx = max(1, idx(1));
    max_idx = min(min_idx+final_length, L);
    sample = sample(min_idx:max_idx);
end


%% compute_spectrogram
% This function computes the spectrogram of a double array representing an
% audio signal, designing the filter in the Bark domain.
%
% spec = compute_spectrogram(x, fs)
%
% Input:
%   x is the (samples x 1) double array representing an audio signal
%   fs is the sampling frequency which has been used to record the audio
%       signal
%
% Output:
%   spec is the (frequency bands x windows) spectrum of the audio signal.

function spec = compute_spectrogram(x, fs)
    fft_length = 512;
    window_length = 320;
    hop_length = 80;
    nBands = 50;
    range = [50 7000];
    overlap = window_length-hop_length;
    
    range = 13.*atan(0.00076.*range) + 3.5.*atan((range./7500).^2);
    cf = 650.*sinh(abs(linspace(range(1), range(2), nBands+2))./7);
    nRow = size(x, 1);
    
    filter_bank = auditory_filter_bank(fs, cf, fft_length)';
    nHops = fix((nRow-window_length)/hop_length) + 1;
    win = hann(window_length, 'periodic');
    window = repmat(win, 1, nHops);
    
    spec = zeros(nBands, nHops, 'like', x);
    ncol = floor((nRow-overlap)/(hop_length));
    offset = (0:(ncol-1))*(hop_length);
    idx = (1:window_length)'+offset;
    X = abs(fft(x(idx).*window, fft_length));
    for i = 1:size(window, 2)
        spec(:, i) = filter_bank*X(:, i);
    end
end


%% auditory_filter_bank
% This function designes the auditory filter bank in the Bark domain.
%
% filter_bank = auditory_filter_bank(fs, cf, fft_length)
%
% Input:
%   fs is the sampling frequency
%   cf is the list of cut frequencies
%   fft_length is the number of bins in the DTFT
%
% Output:
%   filter_bank is the auditory filter bank

function filter_bank = auditory_filter_bank(fs, cf, fft_length)
    nEdges = size(cf, 2);
    nBands = nEdges-2;
    valid_nEdges = sum(cf<floor(fs/2));
    valid_nBands = valid_nEdges - 2;
    filter_bank = zeros(fft_length,nBands);
    frequencies = (0:fft_length-1)/fft_length*fs;
    p = zeros(valid_nEdges, 1);
    for i = 1:valid_nEdges
        p(i) = find(frequencies > cf(i), 1, 'first');
    end
    
    bw = diff(cf);
    for i = 1:valid_nBands
        filter_bank(p(i):p(i+1)-1,i) = ...
            (frequencies(p(i):p(i+1)-1)-cf(i))/bw(i);
        filter_bank(p(i+1):p(i+2)-1, i) = ...
            (cf(i+2)-frequencies(p(i+1):p(i+2)-1))/bw(i+1);
    end
    filterBandWidth = cf(3:end)-cf(1:end-2);
    weightPerBand = 2./filterBandWidth;
    for i = 1:nBands
        filter_bank(:,i) = filter_bank(:,i).*weightPerBand(i);
    end
end