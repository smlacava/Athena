%% PSDr
% This function computes the Power Spectral Density relative over a total
% band defined by the user, using the Welch's power formulation.
%
% PSDr(fs, cf, nEpochs, dt, inDir, outDir, tStart, cfstart, cfstop)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 4 8 13 30 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch (0 as default)
%   cfstart is the index of the first minimum cf value's step to save (1 as
%       default)
%   cfstop is the index of the last maximum cf value's step to save
%       (length(cf) as default)
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
    
    f = waitbar(0,'Processing your data', 'Color', '[0.67 0.98 0.92]');
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
            if fsOld ~= fs
                [p, q] = rat(fs/fsOld);
                time_series = resample(time_series', p, q)';
            end
            time_series = time_series(:, tStart:end);
            psdr.data = zeros(nBands, nEpochs, size(time_series, 1));
            psdr.locations = locations;
            for k = 1:nEpochs
        
                for j = 1:size(time_series, 1)
                    data = squeeze(time_series(j, dt*(k-1)+1:k*dt));           
                    [pxx, w] = pwelch(data, [], 0, [], fs);
                    bandPower = zeros(nBands, 1);

                    for b = 1:nBands
                        fPre = [find(w > cf(b+cfstart), 1), ...
                            find(w > cf(b+cfstart), 1)-1];
                        [~,y] = min([w(fPre(1))-cf(b+cfstart), ...
                            cf(b+cfstart)-w(fPre(2))]);
                        infft = fPre(y);
                
                        fPost = [find(w > cf(b+cfstart+1), 1), ...
                            find(w > cf(b+cfstart+1), 1)-1];
                        [~,y] = min([w(fPost(1))-cf(b+cfstart+1), ...
                            cf(b+cfstart+1)-w(fPost(2))]);
                        supft = fPost(y);

                        bandPower(b, 1) = sum(pxx(infft:supft));
                    end     
            
                    fPre = [find(w>relBand(1), 1), ...
                        find(w > relBand(1), 1)-1];
                    [~, y] = min([w(fPre(1))-relBand(1), ...
                        relBand(1)-w(fPre(2))]);
                    infft = fPre(y);
                
                    fPost = [find(w > relBand(end), 1), ...
                        find(w > relBand(end), 1)-1];
                    [~, y] = min([w(fPost(1))-relBand(end), ...
                        relBand(end)-w(fPost(2))]);
                    supft = fPost(y);

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