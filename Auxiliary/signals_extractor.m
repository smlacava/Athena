%% signals_extractor
% This function extracts all the signals contained inside a directory and
% save them in a .mat format inside a subdirecotry of the main folder named
% Converted, and can also resample them to a chosen frequency (if the 
% sample frequency is not present in a file, the one chosen by the user is 
% considered)
%
% signals_extractor(dataPath, fs)
%
% input:
%   dataPath is the directory which contains the signals
%   fs is the final sample frequency (optional)


function signals_extractor(dataPath, fs)
    if nargin < 2
        fs = [];
    end
    cases = define_cases(dataPath);
    dataPath = path_check(dataPath);
    n_cases = length(cases);
    
    f = waitbar(0,'Extracting your data', ...
        'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    outDir = path_check(strcat(dataPath, 'Converted'));
    create_directory(outDir);
    
    for i = 1:n_cases
        data = struct();
        name = split(cases(i).name, '.');
        name = name{1};
        [time_series, fsOld, locs] = load_data(strcat(dataPath, ...
            cases(i).name));
        if not(isempty(fs)) && not(isempty(fsOld))
            [p, q] = rat(fs/fsOld);
            time_series = resample(time_series', p, q)';
        end
        data.time_series = time_series;
        if isempty(fs)
        	data.fs = fsOld;
        else
            data.fs = fs;
        end
        if not(isempty(locs))
            data.locations = locs;
        end
        save(strcat(outDir, name, '.mat'), 'data')
        waitbar(i/n_cases, f);
    end
    close(f)
end