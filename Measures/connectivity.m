%% connectivity
% This function computes the connectivity between EEG channels or ROIs,
% using the phase locking value (PLV), the phase lag index (PLI), the
% magnitude-squared coherence (MSC), the amplitude envelope correlation 
% corrected (also called orthogonalized, AECo), the amplitude envelope 
% correlation not corrected (AEC), the mutual information (MI), or the
% weighted phase lag index (wPLI).
%
% connectivity(fs, cf, nEpochs, dt, inDir, tStart, outTypes, filter_name)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch
%   outTypes is the list of connectivity types to compute (PLI, PLV, etc.)
%   filter_name is the name of the filtering function (athena_filter as
%       default)

function vargout = connectivity(fs, cf, nEpochs, dt, inDir, tStart, outTypes, ...
    filter_name)

    switch nargin
        case 5
            tStart=0;
            outTypes="";
            filter_name = 'athena_filter';
        case 6
            outTypes="";
            filter_name = 'athena_filter';
        case 7
            filter_name = 'athena_filter';
    end
    
    vargout = -1;
    f = waitbar(0, 'Processing your data', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    askList = 'Insert the connectivity measures separated by a comma';
    
    filter_handle = eval(strcat('@', filter_name));
	dt = fs*dt;
    tStart = tStart*fs+1; 
    nBands = length(cf)-1;
    
    PLInames = ["pli", "PLI", "Pli"];
    PLVnames = ["plv", "PLV", "Plv"];
    AECnames = ["aec", "AEC", "Aec"];
    AECOnames = ["aeco", "aec_o", "AECo", "AEC_o", "Aeco", "Aec_o", ...
        "AECc", "AEC_c", "aecc", "aec_c", "Aecc", "Aec_c"];
    MSCnames = ["coherence", "MSC", "coh", "msc", "COH", "Coherence"];
    ICOHnames = ["ICOH", "Coherency", "coherency"];
    MInames = ["mutual_information", "MI", "Mutual_Information"];
    CCnames = ["correlation", "correlation_coefficient", "CC"];
    wPLInames = ["wPLI", "w_PLI"];
    
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
            if contains(sup(i, 1), wPLInames)
            	outTypes = [outTypes, "wPLI"];
            elseif contains(sup(i, 1), PLVnames)
                outTypes = [outTypes, "PLV"];
            elseif contains(sup(i, 1), AECOnames)
                outTypes = [outTypes, "AECo"];
            elseif contains(sup(i, 1), AECnames)
                outTypes = [outTypes, "AEC"];
            elseif contains(sup(i, 1), MSCnames)
                outTypes = [outTypes, "coherence"];
            elseif contains(sup(i, 1), ICOHnames)
                outTypes = [outTypes, "ICOH"];
            elseif contains(sup(i, 1), MInames)
                outTypes = [outTypes, "mutual_information"];
            elseif contains(sup(i, 1), CCnames)
                outTypes = [outTypes, "correlation_coefficient"];
            elseif contains(sup(i, 1), PLInames)
                outTypes = [outTypes, "PLI"];
            end
        end
        if length(outDirs) == length(outTypes)
           ctrl = 0;
        end
    end
    
    for i = 1:length(outTypes)
        if contains(outTypes(i), wPLInames)
        	outTypes(i) = "wPLI";
        elseif contains(outTypes(i), PLVnames)
        	outTypes(i) = "PLV";
        elseif contains(outTypes(i), AECOnames)
        	outTypes(i) = "AECo";
        elseif contains(outTypes(i), AECnames)
        	outTypes(i) = "AEC";
        elseif contains(outTypes(i), ICOHnames)
            outTypes(i) = "ICOH";
        elseif contains(outTypes(i), MSCnames)
            outTypes(i) = "coherence";
        elseif contains(outTypes(i), MInames)
            outTypes(i) = "mutual_information";
        elseif contains(outTypes(i), CCnames)
            outTypes(i) = "correlation_coefficient";
        elseif contains(outTypes(i), PLInames)
            outTypes(i) = "PLI";
        end
    end
    
    [time_series, fsOld] = load_data(strcat(inDir, cases(i).name), 1);
    time_series = resample_signal(time_series, fs, fsOld);
    check = check_filtering(time_series, dt, tStart, fs, cf, ...
        filter_handle);
    if check
        close(f)
        return;
    end
    
    for c = 1:length(outTypes)
        for i = 1:length(cases)
            try
                [time_series, fsOld, locations, chanlocs] = ...
                    load_data(strcat(inDir, cases(i).name), 1);
                time_series = resample_signal(time_series, fs, fsOld);
                nLoc = size(time_series, 1);
                conn.data = zeros(nBands, nEpochs, nLoc, nLoc);
                conn.locations = locations;
                conn.chanlocs = chanlocs;
                for j = 1:nBands
                    for k = 1:nEpochs
                        ti = ((k-1)*dt)+tStart;
                        tf = k*dt+tStart-1;
                        data = filter_handle(time_series(:, ti:tf), fs, ...
                            cf(j), cf(j+1));                 
                        data = data';
                        if strcmpi(outTypes(c), "PLI")
                            conn.data(j, k, :, :) = phase_lag_index(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "PLV")
                            conn.data(j, k, :, :) = ...
                                phase_locking_value(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "AECo")
                            conn.data(j, k, :, :) = ...
                                amplitude_envelope_correlation_orth(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "AEC")
                            conn.data(j, k, :, :) = ...
                                amplitude_envelope_correlation(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "coherence")
                            conn.data(j, k, :, :) = ...
                                magnitude_squared_coherence(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "ICOH")
                            conn.data(j, k, :, :) = ...
                                imaginary_coherency(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "mutual_information")
                            conn.data(j, k, :, :) = ...
                                mutual_information(data, 'max');
                            vargout = 0;
                        elseif strcmpi(outTypes(c), ...
                                "correlation_coefficient")
                            conn.data(j, k, :, :) = ...
                                correlation_coefficient(data);
                            vargout = 0;
                        elseif strcmpi(outTypes(c), "wPLI")
                            conn.data(j, k, :, :) = ...
                                weighted_phase_lag_index(data);
                            vargout = 0;
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
                save(fullfile_check(filename), 'conn');
            catch
            end %end try
            waitbar((i+(c-1)*length(cases))/...
                (length(cases)*length(outTypes)), f)
        end
    end
    close(f)
end