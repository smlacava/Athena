%% autocorrelation_measures
% This function computes the autocorrelation evaluation related to EEG 
% channels or ROIs.
%
% autocorrelation_measures(fs, cf, nEpochs, dt, inDir, outDirs, tStart, ...
%         outTypes, filter_name)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch
%   outTypes is the list of autocorrelation measures to compute (hurst 
%       exponent)
%   filter_name is the name of the filtering function (athena_filter as
%       default)


function autocorrelation_measures(fs, cf, nEpochs, dt, inDir, tStart, ...
    outTypes, filter_name)

    if nargin < 6
        tStart = 0;
    end
    if nargin < 7
        outTypes = "";
    end
    if nargin < 8
        filter_name = 'athena_filter';
    end
    if nargin < 9
        m = 2;
    end
    if nargin < 10
        r = 0.2;
    end
    
    f = waitbar(0, 'Processing your data', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    askList = 'Insert the autocorrelation measures separated by a comma';
    
    filter_handle = eval(strcat('@', filter_name));
	dt = fs*dt;
    tStart = tStart*fs+1; 
    nBands = length(cf)-1;
    
    hurst_names = ["hurst_exponent", "hurst"];
    
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
            if contains(sup(i, 1), hurst_names)
            	outTypes = [outTypes, "Hurst"];
            end
        end
        if length(outDirs) == length(outTypes)
           ctrl = 0;
        end
    end
    
    for i = 1:length(outTypes)
        if contains(outTypes(i), hurst_names)
        	outTypes(i) = "Hurst";
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
                he.data = zeros(nBands, nEpochs, nLoc);
                he.locations = locations;
                he.chanlocs = chanlocs;
                for j = 1:nBands
                    for k = 1:nEpochs
                        for loc = 1:nLoc
                            ti = ((k-1)*dt)+tStart;
                            tf = k*dt+tStart-1;
                            data = filter_handle(...
                                time_series(loc, ti:tf), fs, cf(j), ...
                                cf(j+1));                 
                            data = data';
                            if strcmpi(outTypes(c), "Hurst")
                                he.data(j, k, loc) = ...
                                    hurst_exponent(data);                            
                            end
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
                save(filename, 'he');
            catch
            end %end try
            waitbar((i+(c-1)*length(cases))/...
                (length(cases)*length(outTypes)), f)
        end
    end
    close(f)
end