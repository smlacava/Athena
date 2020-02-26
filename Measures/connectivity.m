%% connectivity
% This function computes the connectivity between EEG channels or ROIs,
% using the phase locking value (PLV), the phase lag index (PLI), the
% amplitude envelope correlation corrected (also called orthogonalized, 
% AECo) or the amplitude envelope correlation not corrected (AEC).
%
% connectivity(fs, cf, nEpochs, dt, inDir, outDirs, tStart, outTypes)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch
%   outTypes is the list of variables to save (PLI, PLV, AEC, AECo)


function connectivity(fs, cf, nEpochs, dt, inDir, tStart, outTypes)
    switch nargin
        case 5
            tStart=0;
            outTypes="";
        case 6
            outTypes="";
    end
    
    f = waitbar(0, 'Processing your data', 'Color', '[0.67 0.98 0.92]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    askList = 'Insert the connectivity measures separated by a comma';
    
	dt = fs*dt;
    tStart = tStart*fs+1; 
    nBands = length(cf)-1;
    
    PLInames = ["pli", "PLI", "Pli"];
    PLVnames = ["plv", "PLV", "Plv"];
    AECnames = ["aec", "AEC", "Aec"];
    AECOnames = ["aeco", "aec_o", "AECo", "AEC_o", "Aeco", "Aec_o", ...
        "AECc", "AEC_c", "aecc", "aec_c", "Aecc", "Aec_c"];
    
    inDir = path_check(inDir);
    cases = define_cases(inDir);
    outTypes = string(outTypes);
    
    ctrl = 0;
    if length(outTypes) == 1
        if strcmp(outTypes,'')
            ctrl = 1;
        end
    end
    
    while ctrl == 1
    	outTypes = [];
        sup = string(inputdlg(askList));
        if strcmp(sup, 'exit')
        	return
        end
        sup = split(sup, ',');
        for i = 1:length(sup)
            if contains(sup(i, 1), PLInames)
            	outTypes = [outTypes, "PLI"];
            elseif contains(sup(i, 1), PLVnames)
                outTypes = [outTypes, "PLV"];
            elseif contains(sup(i, 1), AECOnames)
                outTypes = [outTypes, "AECo"];
            elseif contains(sup(i, 1), AECnames)
                outTypes = [outTypes, "AEC"];
            end
        end
        if length(outDirs) == length(outTypes)
           ctrl = 0;
        end
    end
    
    for i = 1:length(outTypes)
        if contains(outTypes(i), PLInames)
        	outTypes(i) = "PLI";
        elseif contains(outTypes(i), PLVnames)
        	outTypes(i) = "PLV";
        elseif contains(outTypes(i), AECOnames)
        	outTypes(i) = "AECo";
        elseif contains(outTypes(i), AECnames)
        	outTypes(i) = "AEC";
        end
    end


    for c = 1:length(outTypes)
        for i = 1:length(cases) 
            try
                [time_series, fsOld, locations] = ...
                    load_data(strcat(inDir, cases(i).name), 1);
                if fsOld ~= fs
                    [p, q] = rat(fs/fsOld);
                    time_series = resample(time_series', p, q)';
                end
                nLoc = size(time_series, 1);
                conn.data = zeros(nBands, nEpochs, nLoc, nLoc);
                conn.locations = locations;
                for j = 1:nBands
                    for k = 1:nEpochs
                        ti = ((k-1)*dt)+tStart;
                        tf = k*dt+tStart-1;
                        data = athena_filter(time_series(:, ti:tf), fs, ...
                            cf(j), cf(j+1));                 
                        data = data';
                        if strcmp(outTypes(c), "PLI")
                            conn.data(j, k, :, :) = phase_lag_index(data);
                        elseif strcmp(outTypes(c), "PLV")
                            conn.data(j, k, :, :) = ...
                                phase_locking_value(data);
                        elseif strcmp(outTypes(c), "AECo")
                            conn.data(j, k, :, :) = ...
                                amplitude_envelope_correlation_orth(data);
                        elseif strcmp(outTypes(c), "AEC")
                            conn.data(j, k, :, :) = ...
                                amplitude_envelope_correlation(data);
                        end
                    end
                end
                outDir = path_check(subdir(inDir, outTypes(c)));            
                name = split(cases(i).name, '\');
                if length(name) == 1
                    name = split(cases(i).name, '\');
                end
                if length(name) > 1
                    name = name{2};
                else
                    name = cases(i).name;
                end
                filename = strcat(outDir, strtok(name, '.'), '.mat');
                save(filename, 'conn');
            catch
            end %end try
            waitbar((i+(c-1)*length(cases))/...
                (length(cases)*length(outTypes)), f)
        end
    end
    close(f)
end