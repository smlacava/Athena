%% FOOOFer
% This function parameterizes the neural power spectra using the Haller et
% al. method.
%
% FOOOFer(fs, cf, nEpochs, dt, inDir, tStart, outTypes)
%
% input:
%   fs is the sampling frequency
%   cf is an array containing the cut frequencies (es, [1 40])
%   nEpochs contains the number of epochs to compute
%   dt contains the time (in seconds) of each epoch
%   inDir is the directory containing each case
%   tStart is the starting time (in seconds) to computate the first sample
%       of the first epoch
%   outTypes is the list of variables to save (offset, exponent,
%       peak parameters, gaussian parameters, error, r squared, fooofed 
%       spectrum, bg fit, power spectrum), writen in an array as strings 
%       in the same order as their output directories in the variable 
%       outDirs (es. outDirs=["C:\offset\", "C:\exponent", "C:\bg_fit"], 
%       outTypes=["offset", "exponent", "bg fit"])
%
% NB: peak and gaussian params will contain a matrix where every group of 3
%     numbers are relative to one peak (CF, Amp, BW) and the others zeros 
%     are utilized to export only one matrix for each subject

function [] = FOOOFer(fs, cf, nEpochs, dt, inDir, tStart, outTypes, ...
    maxPeaks)

    switch nargin
        case 5
            tStart=0;
            outTypes = "";
            maxPeaks = (cf(end)-cf(1))*2;
        case 6
            outTypes = "";
            maxPeaks = (cf(end)-cf(1))*2;
        case 7
            maxPeaks = (cf(end)-cf(1))*2;
    end
           
    f = waitbar(0, 'Processing your data');
    f.Color = [0.67 0.98 0.92];
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
	dt = fs*dt;
    tStart = tStart*fs+1;    
    
    askList = 'Insert the background measures separated by a comma';
    
    inDir = path_check(inDir);
    cases = define_cases(inDir);

    if strcmp(outTypes, "")
    	outTypes = [];
        sup = string(inputdlg(askList));
        if stcmp(sup, "exit")
            return
        end
        sup = split(sup,",");
        for i = 1:length(sup)
            if contains(sup(i, 1), ["Exp", "exp", "EXP"])
                outTypes = [outTypes, "exp"];
            elseif contains(sup(i, 1), ["off", "OFF", "Off"])
                outTypes = [outTypes, "off"];
            elseif contains(sup(i, 1), ["peak", "PEAK", "Peak"])
                outTypes = [outTypes, "peak_params"];
            elseif contains(sup(i, 1), ["gau", "GAU", "Gau"])
                outTypes = [outTypes, "gaussian_params"];
            elseif contains(sup(i, 1), ["err", "ERR", "Err"])
                outTypes = [outTypes, "error"];
            elseif contains(sup(i, 1), ["squar", "Squar", "SQUAR"])
                outTypes = [outTypes, "r_squared"];
            elseif contains(sup(i, 1), ["foo", "FOO", "Foo"])
                outTypes = [outTypes, "fooofed_spectrum"];
            elseif contains(sup(i, 1), ["bg", "BG", "Bg"])
                outTypes = [outTypes, "bg_fit"];
            elseif contains(sup(i, 1), ["pow", "POW", "Pow"])
                outTypes = [outTypes, "power_spectrum"];
            end
        end
    end
    
    for i = 1:length(outTypes)
        if contains(outTypes(i), ["Exp","exp","EXP"])
        	outTypes(i) = "exponent";
        elseif contains(outTypes(i), ["off","OFF", "Off"])
        	outTypes(i) = "offset";
        elseif contains(outTypes(i), ["peak","PEAK", "Peak"])
        	outTypes(i) = "peak_params";
        elseif contains(outTypes(i), ["gau","GAU", "Gau"])
        	outTypes(i) = "gaussian_params";
        elseif contains(outTypes(i), ["err","ERR", "Err"])
        	outTypes(i) = "error";
        elseif contains(outTypes(i), ["squar","Squar", "SQUAR"])
            outTypes(i) = "r_squared";
        elseif contains(outTypes(i), ["foo","FOO", "Foo"])
            outTypes(i) = "fooofed_spectrum";
        elseif contains(outTypes(i), ["bg","BG", "Bg", "fit", "FIT", ...
                "Fit"])
            outTypes(i) = "bg_fit";
        elseif contains(outTypes(i), ["pow","POW", "Pow"])
            outTypes(i) = "power_spectrum";
        end
    end

    % initial setting
    settings = struct();
    settings.max_n_peaks = maxPeaks;
    time_series = load_data(strcat(inDir, cases(1).name));
    time_series = time_series(:, tStart:end);
    data = squeeze(time_series(1, 1:dt));           
    [pxx, w] = pwelch(data, [], 0, [], fs);
    sup = [find(w > cf(1), 1), find(w > cf(1), 1)-1];
    [x, y] = min([w(find(w > cf(1), 1))-cf(1), ...
        cf(1)-w(find(w > cf(1), 1)-1)]);
    inferior = sup(y);
    sup = [find(w > cf(end), 1), find(w > cf(end), 1)-1];
    [x,y] = min([w(find(w > cf(end), 1))-cf(end), ...
        cf(end)-w(find(w > cf(end), 1)-1)]);
    superior = sup(y);
    f_range_ind = [inferior superior];
    f_range = [w(inferior) w(superior)];
    clear time_series

   
    for i = 1:length(cases)
        time_series = load_data(strcat(inDir, cases(i).name));
        time_series = time_series(:, tStart:end);
        nLoc = size(time_series, 1);
        offset = zeros(nEpochs, nLoc);   %epochs * locations
        exponent = offset;
        error = offset;
        r_squared = offset;
        peak_params = zeros(nEpochs, nLoc, maxPeaks*3);
        gaussian_params = peak_params;
        fooofed_spectrum = zeros(nEpochs, nLoc, ...
            f_range_ind(2)-f_range_ind(1)+1);
        bg_fit = fooofed_spectrum;
        power_spectrum = bg_fit;
        for k = 1:nEpochs
            for j = 1:nLoc
                data = squeeze(time_series(j, dt*(k-1)+1:k*dt));           
                [pxx, w] = pwelch(data, [], 0, [], fs);
                fooof_results = fooof(w', pxx, f_range, settings, 1);
                offset(k, j) = fooof_results.background_params(1);
                exponent(k, j) = fooof_results.background_params(2);
                r_squared(k, j) = fooof_results.r_squared;
                error(k, j) = fooof_results.error;
                fooofed_spectrum(k, j, :) = fooof_results.fooofed_spectrum;
                bg_fit(k, j, :) = fooof_results.bg_fit;
                power_spectrum(k, j, :) = fooof_results.power_spectrum;
                
                sizePeaks = size(fooof_results.peak_params, 1)*3;
                peak_params(k, j, 1:sizePeaks) = squeeze(reshape(...
                    fooof_results.peak_params', 1, sizePeaks));
                gaussian_params(k, j, 1:sizePeaks) = squeeze(reshape(...
                    fooof_results.gaussian_params', 1, sizePeaks));
                
            end
        end
        
        for s = 1:length(outTypes)  
            outDir = strcat(inDir, outTypes(s));
            outDir = path_check(outDir);
            if not(exist(outDir, 'dir'))
                mkdir(inDir, outTypes(s))
            end
            filename = strcat(outDir, strtok(cases(i).name, '.'), '.mat');    
            save(filename, outTypes(s)); 
        end
        clear time_series
        waitbar(i/length(cases), f)
    end
    close(f)
end