%% spectral_entropy
% This function computes the Spectral Entropy, on the single frequency
% bands and on the single epochs.
%
% spectral_entropy(fs, cf, nEpochs, dt, inDir, outDir, tStart)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 4 8 13 30 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch (0 as default)


function spectral_entropy(fs, cf, nEpochs, dt, inDir, tStart)
    switch nargin
        case 5
            tStart = 0;
    end
    
    f = waitbar(0,'Processing your data', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    cfstart = 0;
    cfstop = length(cf)-1;         
    nBands = cfstop-cfstart;
    dt = fs*dt;
    tStart = tStart*fs+1;
    inDir = path_check(inDir);
    
    cases = define_cases(inDir);

    for i = 1:length(cases)
        try
            [time_series, fsOld, locations, chanlocs] = ...
                load_data(strcat(inDir, cases(i).name), 1);
            time_series = resample_signal(time_series, fs, fsOld);
            time_series = time_series(:, tStart:end);
            se.data = zeros(nBands, nEpochs, size(time_series, 1));
            se.locations = locations;
            se.chanlocs = chanlocs;
            for k = 1:nEpochs
        
                for j = 1:size(time_series, 1)
                    data = squeeze(time_series(j, dt*(k-1)+1:k*dt));           
                    for b = 1:nBands
                        [p, fp, tp] = pspectrum(data, fs, 'spectrogram');
                        se.data(b, k, j) = pentropy(p, fp, tp, ...
                            'Instantaneous', false, ...
                            'FrequencyLimits', [cf(b), cf(b+1)]);  
                    end
                end
            end
        
            outDir = path_check(subdir(inDir, 'PEntropy'));
            name = split(cases(i).name, filesep);
            if length(name) > 1
                name = name{2};
            else
                name = cases(i).name;
            end
            filename = strcat(outDir, strtok(name, '.'), '.mat');
    
            save(fullfile_check(filename), 'se'); 
        catch
        end
        waitbar(i/length(cases), f)
    end
    close(f)
end