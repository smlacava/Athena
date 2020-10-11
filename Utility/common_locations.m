%% common_locations
% This function returns the common locations of a set of time series
% contained inside a directory.
%
% locations = common_locations(dataPath, saveFLAG)
%
% Input:
%   dataPath is the directory which contains the time series files
%   saveFLAG has to be 1 in order to save the time series, deleting all the
%       uncommon locations, in a subdirectory named 'Common_Locations', 0
%       otherwise (0 by default)
%
% Output:
%   locations is the cell array which contains all the common locations
%       (note that the locations named as only numbers are deleted, as well
%       as the prefixes EEG and MEG and the suffixes LE and REF for each
%       location)
       

function locations = common_locations(dataPath, saveFLAG)
    if nargin == 1
        saveFLAG = 0;
    end
    
    f = waitbar(0,'Identification of the common locations', 'Color', ...
        '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    dataPath = path_check(dataPath);
    cases = define_cases(dataPath);
    N = length(cases);
    [~, ~, locations] = load_data(strcat(dataPath, cases(1).name));
    locations = locations_check(locations);
    
    if N > 1
        for i = 2:N
            waitbar((i-1)/length(cases), f)
            if isempty(locations)
                break;
            end
            [~, ~, locs] = load_data(strcat(dataPath, cases(i).name));
            locs = locations_check(locs);
            [~, del_ind] = match_locations(locations, locs);
            locations(del_ind) = [];
        end
        waitbar(i/N, f)
    end
    
    locations = delete_number_only(locations);
    close(f);
    if isempty(locations)
        disp('No common locations')
        return;
    end
    
    if saveFLAG == 1
        save_with_common_locations(dataPath, locations);
    end
end
        

%% locations_check
% This function is used to delete some suffixes and some prefixes from each
% location name
% 
% locs = locations_check(locs)
%
% Input:
%   locs is the cell array which contains the names of the locations
%
% Output:
%   locs is the resulting cell array

function locs = locations_check(locs)
    pre = {"MEG", "EEG"};
    post = {"REF", "LE"};
    
    for i = 1:length(locs)
        for j = 1:length(pre)
            aux = split(locs{i}, pre{j});
            if length(aux) == 2
                locs{i} = aux{2};
            end
        end
        
        for j = 1:length(post)
            aux = split(locs{i}, post{j});
            if length(aux) == 2
                locs{i} = aux{1};
            end
        end
    end
end
        

%% delete_number_only
% This function is used to delete the names of the locations identified by
% a number only
%
% locs = delete_number_only(locs)
%
% Input:
%   locs is the cell array which contains the name of each location
%
% Output:
%   locs is the resulting cell array having the only numeric locations
%       deleted

function locs = delete_number_only(locs)
    del_ind = [];
    for i = 1:length(locs)
        if not(isnan(str2double(locs{i})))
            del_ind = [del_ind, i];
        end
    end
    locs(del_ind) = [];
end


%% save_with_common_locations
% This function saves each time series by considering the only common
% locations, sorting them in the same order too
%
% save_with_common_locations(dataPath, locations)
%
% Input:
%   dataPath is the directory which contains all the files related to the
%       time series, in the same format (.edf, .mat, etc.)
%   locations is the cell array which contains the common locations

function save_with_common_locations(dataPath, locations)
    
    f = waitbar(0,'Saving the only common locations', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    cases = define_cases(dataPath);
    data = struct();
    outPath = path_check(create_directory(dataPath, 'Common_Locations'));
    N = length(cases);
    
    for i = 1:N
        [ts, fs, locs] = load_data(strcat(dataPath, cases(i).name));
        locs = locations_check(locs);
        [ind, ~] = match_locations(locations, locs);
        
        data.time_series = ts(ind, :);
        data.fs = fs;
        data.locations = locations;
        
        save(strcat(outPath, strtok(cases(i).name, '.'), '.mat'), 'data')
        
        waitbar(i/N, f)
    end
    close(f)
end
        