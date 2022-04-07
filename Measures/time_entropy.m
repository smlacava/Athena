%% time_entropy
% This function computes the entropy related to EEG channels or ROIs.
%
% time_entropy(fs, cf, nEpochs, dt, inDir, outDirs, tStart, outTypes, ...
%         filter_name, m, r)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch
%   outTypes is the list of entropy types to compute (sample_entropy, 
%       approximate entropy or discretized entropy)
%   filter_name is the name of the filtering function (athena_filter as
%       default)
%   m is the embedding dimension (its maximum value is the number of
%       samples of the time series minus 1, 2 by default)
%   r is the fraction of standard deviation of the time series, which have
%       to be used as tolerance (0.2 by default)


function vargout = time_entropy(fs, cf, nEpochs, dt, inDir, tStart, outTypes, ...
    filter_name, m, r)

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
    askList = 'Insert the entropy measures separated by a comma';
    
    vargout = -1;
    filter_handle = eval(strcat('@', filter_name));
	dt = fs*dt;
    tStart = tStart*fs+1; 
    nBands = length(cf)-1;
    
    SampEn_names = ["sample_entropy", "SampEn", "SaEn"];
    AppEn_names = ["approximate_entropy", "AppEn", "ApEn"];
    DiscEn_names = ["discretized_entropy", "DiscEn", "DE"];
    
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
            if contains(sup(i, 1), SampEn_names)
            	outTypes = [outTypes, "sample_entropy"];
            elseif contains(sup(i, 1), DiscEn_names)
                outTypes = [outTypes, "discretized_entropy"];
            elseif contains(sup(i, 1), AppEn_names)
                outTypes = [outTypes, "approximate_entropy"];
            end
        end
        if length(outDirs) == length(outTypes)
           ctrl = 0;
        end
    end
    
    for i = 1:length(outTypes)
        if contains(outTypes(i), SampEn_names)
        	outTypes(i) = "sample_entropy";
        elseif contains(outTypes(i), DiscEn_names)
            outTypes(i) = "discretized_entropy";
        elseif contains(outTypes(i), AppEn_names)
        	outTypes(i) = "approximate_entropy";
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
                en.data = zeros(nBands, nEpochs, nLoc);
                en.locations = locations;
                en.chanlocs = chanlocs;
                for j = 1:nBands
                    for k = 1:nEpochs
                        for loc = 1:nLoc
                            ti = ((k-1)*dt)+tStart;
                            tf = k*dt+tStart-1;
                            data = filter_handle(...
                                time_series(loc, ti:tf), fs, cf(j), ...
                                cf(j+1));                 
                            data = data';
                            if strcmpi(outTypes(c), "sample_entropy")
                                en.data(j, k, loc) = ...
                                    sample_entropy(data, m, r);
                                vargout = 0;
                            elseif strcmpi(outTypes(c), ... 
                                    "discretized_entropy")
                                en.data(j, k, loc) = ...
                                    discretized_entropy(data);
                                vargout = 0;
                            elseif strcmpi(outTypes(c), ...
                                    "approximate_entropy")
                                en.data(j, k, loc) = ...
                                    approximate_entropy(data, m, r);
                                vargout = 0;
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
                save(fullfile_check(filename), 'en');
            catch
            end %end try
            waitbar((i+(c-1)*length(cases))/...
                (length(cases)*length(outTypes)), f)
        end
    end
    close(f)
end