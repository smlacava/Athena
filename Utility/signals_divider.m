%% signals_divider
% This function divides all the signals contained inside a directory in a
% chosen number of segments, having the selected time length, and saves
% them in different file, which name will be the concatenation between the
% original file name and a label which identifies the number of the related
% segment (for example, seg2 is the second segment)
%
% signals_divider(dataPath, time_window, n_time_series, fs)
%
% input:
%   dataPath is the directory which contains the signals
%   time_window is the time length of each segment
%   n_time_series is the number of segments which have to be extracted from
%       each signal


function signals_divider(dataPath, time_window, n_time_series, fs)
    if nargin < 3
        n_time_series = [];
    end
    if nargin < 4
        fs = [];
    end
    cases = define_cases(dataPath);
    dataPath = path_check(dataPath);
    f = waitbar(0,'Initial setup process', ...
        'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    % setup
    seg_names = string(1:n_time_series);
    [time_series, fsOld] = load_data(strcat(dataPath, cases(1).name));
    if length(time_series) < n_time_series*fsOld*time_window
        return;
    end
    if not(isempty(fsOld)) && isempty(fs)
        fs = fsOld;
    end
    data = struct();
    outDir = path_check(create_directory(dataPath, 'Segmented'));
    time_window = time_window*fs;
    
    waitbar(0, f, 'Processing your data');
    n_cases = length(cases);
    
    % divider
    try
        for i = 1:n_cases
            name = define_case_name(cases(i).name);            
            [time_series, fsOld, locs, chanlocs] = ...
                load_data(strcat(dataPath, cases(i).name));
            if not(isempty(fs)) && not(isempty(fsOld))
                [p, q] = rat(fs/fsOld);
                time_series = resample(time_series', p, q)';
            end
            for n = 1:n_time_series
                initial = (n-1)*time_window+1;
                final = n*time_window;
                data.time_series = time_series(:, initial:final);
                if isempty(fs)
                    data.fs = fsOld;
                else
                    data.fs = fs;
                end
                if not(isempty(locs))
                    data.locations = locs;
                end
                if not(isempty(chanlocs))
                    data.chanlocs = chanlocs;
                end
                save(strcat(outDir, name, 'seg', seg_names(n), '.mat'), ...
                    'data')
            end
            waitbar(i/n_cases, f);
        end
    catch
        problem('Segmentation failed')
    end
    close(f)
end


function name = define_case_name(name)
    name = split(name, filesep);
    if length(name) > 1
        name = name{2};
    else
        name = name{1};
    end
    name = split(name, '.');
    name = name{1};
end