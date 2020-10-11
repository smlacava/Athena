%% dataset_resample
% This function is used to resample all the signal contained inside a
% directory with a common sampling frequency (the resulting signals will be
% saved in a .mat format, in the subdirectory named 'Resampled').
%
% dataset_resample(dataPath, fs)
%
% Input:
%   dataPath is the directory which contains the signals
%   fs is the new sampling frequency


function dataset_resample(dataPath, fs)
    dataPath = path_check(dataPath);
    cases = define_cases(dataPath);
    outPath = path_check(create_directory(strcat(dataPath, 'Resampled')));
    data = struct();
    
    f = waitbar(0,'Resampling your data', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    for i = 1:length(cases)
        [time_series, fsOld, locs] = ...
            load_data(strcat(dataPath, cases(i).name));
        if not(isempty(fsOld))
            if fs > fsOld
                problem(strcat('The new sampling frequency (', ...
                    string(fs), ...
                    ' Hz) cannot be higher than the older one (', ...
                    string(fsOld), ' Hz)'))
                return
            elseif fsOld > fs
                data.time_series = resample_signal(time_series, fs, fsOld);
            end
        end
        data.locations = locs;
        data.fs = fs;
        save(strcat(outPath, strtok(cases(i).name, '.'), '.mat'), 'data');
        waitbar(i/length(cases), f)
    end
    close(f)
end
        