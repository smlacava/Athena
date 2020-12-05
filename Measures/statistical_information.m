%% statistical_information
% This function computes statistical measures on EEG channels or ROIs.
%
% statistical_information(fs, cf, nEpochs, dt, inDir, outDirs, tStart, ...
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
%   outTypes is the list of statistical measures to compute (median, mean, 
%       std, variance, skewness, kurtosis)
%   filter_name is the name of the filtering function (athena_filter as
%       default)


function statistical_information(fs, cf, nEpochs, dt, inDir, tStart, ...
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
    askList = 'Insert the statistical measures separated by a comma';
    
    filter_handle = eval(strcat('@', filter_name));
	dt = fs*dt;
    tStart = tStart*fs+1; 
    nBands = length(cf)-1;
    
    variance_names = ["variance", "var"];
    mean_names = ["mean"];
    median_names = ["median"];
    std_names = ["std", "standard_deviation"];
    kurtosis_names = ["kurtosis"];
    skewness_names = ["skewness"];
    
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
            if contains(sup(i, 1), variance_names)
            	outTypes = [outTypes, "variance"];
            elseif contains(sup(i, 1), median_names)
                outTypes = [outTypes, "median"];
            elseif contains(sup(i, 1), mean_names)
                outTypes = [outTypes, "mean"];
            elseif contains(sup(i, 1), kurtosis_names)
                outTypes = [outTypes, "kurtosis"];
            elseif contains(sup(i, 1), skewness_names)
                outTypes = [outTypes, "skewness"];
            elseif contains(sup(i, 1), std_names)
                outTypes = [outTypes, "Standard_deviation"];
            end
        end
        if length(outDirs) == length(outTypes)
           ctrl = 0;
        end
    end
    
    for i = 1:length(outTypes)
        if contains(outTypes(i), variance_names)
        	outTypes(i) = "Variance";
        elseif contains(outTypes(i), median_names)
            outTypes(i) = "Median";
        elseif contains(outTypes(i), mean_names)
        	outTypes(i) = "Mean";
        elseif contains(outTypes(i), kurtosis_names)
        	outTypes(i) = "Kurtosis";
            elseif contains(outTypes(i), skewness_names)
        	outTypes(i) = "Skewness";
            elseif contains(outTypes(i), std_names)
        	outTypes(i) = "Standard_deviation";
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
                sa.data = zeros(nBands, nEpochs, nLoc);
                sa.locations = locations;
                sa.chanlocs = chanlocs;
                for j = 1:nBands
                    for k = 1:nEpochs
                        for loc = 1:nLoc
                            ti = ((k-1)*dt)+tStart;
                            tf = k*dt+tStart-1;
                            data = filter_handle(...
                                time_series(loc, ti:tf), fs, cf(j), ...
                                cf(j+1));                 
                            data = data';
                            if strcmpi(outTypes(c), "Variance")
                                sa.data(j, k, loc) = var(data);
                            elseif strcmpi(outTypes(c), ... 
                                    "Standard_deviation")
                                sa.data(j, k, loc) = std(data);
                            elseif strcmpi(outTypes(c), "Mean")
                                sa.data(j, k, loc) = mean(data);
                            elseif strcmpi(outTypes(c), "Median")
                                sa.data(j, k, loc) = median(data);
                            elseif strcmpi(outTypes(c), "Kurtosis")
                                sa.data(j, k, loc) = kurtosis(data);
                            elseif strcmpi(outTypes(c), "Skewness")
                                sa.data(j, k, loc) = skewness(data);
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
                save(filename, 'sa');
            catch
            end %end try
            waitbar((i+(c-1)*length(cases))/...
                (length(cases)*length(outTypes)), f)
        end
    end
    close(f)
end