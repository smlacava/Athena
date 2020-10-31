%% audio_recording
% This function records the audio for a certain time and returns the array
% representing the related audio recording.
%
% rec = audio_recording(fs, duration)
%
% Input:
%   fs is the sampling frequency (16000 Hz by default)
%   duration is the time duration (2 seconds by default)
%
% Output:
%   rec is the array containing the audio samples

function rec = audio_recording(fs, duration)
    if nargin < 1
        fs = 16e3;
    end
    if nargin < 2
        duration = 2;
    end
    
    L = duration*fs;
    deviceReader = audioDeviceReader(fs, L);
    setup(deviceReader);
    
    tic;
    while toc < duration
        rec = record(deviceReader);
    end
    release(deviceReader)
end