%% PSDr
% This function computes the Power Spectral Density relative over a total
% band defined by the user, using the Welch's power formulation.
%
% PSDr(fs, cf, nEpochs, dt, inDir, tStart, relBand)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 4 8 13 30 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch (0 as default)
%   relBand is the total band used to obtain the relative band 
%       ([min(min(cf),1) max(max(cf),40)] as default, the first value is 
%       the minimum between 1 and the first cut frequency and the second
%       value is the maximum between 40 and the last cut frequency)


function PSDr(fs, cf, nEpochs, dt, inDir, tStart, relBand)
    switch nargin
        case 5
            tStart = 0;
            relBand = [min(min(cf), 1) max(max(cf), 40)];
        case 6
            relBand = [min(min(cf), 1) max(max(cf), 40)];
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
    if iscell(relBand)
        aux_relBand = [str2double(string(relBand{1})), ...
            str2double(string(relBand{2}))];
        relBand = aux_relBand;
    end
    
    cases = define_cases(inDir);

    for i = 1:length(cases)
        try
            [time_series, fsOld, locations] = ...
                load_data(strcat(inDir, cases(i).name), 1);
            time_series = resample_signal(time_series, fs, fsOld);
            time_series = time_series(:, tStart:end);
            psdr.data = zeros(nBands, nEpochs, size(time_series, 1));
            psdr.locations = locations;
            for k = 1:nEpochs
        
                for j = 1:size(time_series, 1)
                    data = squeeze(time_series(j, dt*(k-1)+1:k*dt));           
                    [pxx, w] = pwelch(data, [], [], [], fs);
                    bandPower = zeros(nBands, 1);

                    for b = 1:nBands
                        [infft, supft] = band_index(w, cf(b+cfstart), ...
                            cf(b+cfstart+1));

                        bandPower(b, 1) = sum(pxx(infft:supft));
                    end     
                    
                    [infft, supft] = band_index(w, relBand(1), ...
                        relBand(end));
                    totalPower = sum(pxx(infft:supft));             

                    for b = 1:nBands
                        psdr.data(b, k, j) = bandPower(b, 1)/totalPower;  
                    end
                end
            end
        
            outDir = path_check(subdir(inDir, 'PSDr'));
            name = split(cases(i).name, filesep);
            if length(name) > 1
                name = name{2};
            else
                name = cases(i).name;
            end
            filename = strcat(outDir, strtok(name, '.'), '.mat');
    
            save(filename, 'psdr'); 
        catch
        end %end try
        waitbar(i/length(cases), f)
    end
    close(f)
end


%% band_index
% This function computes the minimum value and the maximum value of a
% vector of frequencies, related to the frequency values nearest to two
% different frequencies.
%
% [infft, supft] = band_index(w, min_band, max_band)
%
% Input:
%   w is the vector of frequencies
%   min_band is the minimum frequency to search
%   max_band is the maximum frequency to search
%
% Output:
%   infft is the minimum frequency value
%   supft is the maximum frequency value

function [infft, supft] = band_index(w, min_band, max_band)
    fPre = [find(w > min_band, 1), find(w > min_band, 1)-1];
    [~,y] = min([w(fPre(1))-min_band, min_band-w(fPre(2))]);
    infft = fPre(y);
                
    fPost = [find(w > max_band, 1), find(w > max_band, 1)-1];
    [~,y] = min([w(fPost(1))-max_band, max_band-w(fPost(2))]);
    supft = fPost(y);
end