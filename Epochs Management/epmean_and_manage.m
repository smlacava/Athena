%% epmean_and_manage
% This function computes the epochs mean of the data matrices and saves
% a single data matrix for the subjects realted to the first group (First)
%  and another one for the ones related to the second group (Second).
% 
% [locations_file, sub_types] = epmean_and_manage(inDir, type, subFile, ...
%       locations_file)
%
% input:
%   inDir is the data directory 
%   type is the measure type (offset, plv, aec, etc.)
%   subFile is the file which contains the subjects list with their class
%   locations_file is the name (with its Firsth) of the file which contains
%       the name of each locations (optional)
%
% output:
%   locations_file is the file of the locations
%   sub_types is the list of subjects' types


function [locations_file, sub_types] = epmean_and_manage(inDir, type, ...
    subFile, locations_file)
    
    if nargin == 3
        locations_file = [];
    end
    f = waitbar(0,'Initial setup process', ...
        'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    

    type = char_check(string(type));
    inDir = path_check(inDir);
    if sum(contains(inDir, Athena_measures_list(1))) == 0
        inDir = path_check(strcat(inDir, type));
    end
    epDir = subdir(inDir, 'Epmean');
    epDir = path_check(epDir);
    areasDir = path_check(subdir(epDir, 'Areas'));
    totDir = path_check(subdir(epDir, 'Total'));
    asyDir = path_check(subdir(epDir, 'Asymmetry'));
    globDir = path_check(subdir(epDir, 'Global'));
    hemiDir = path_check(subdir(epDir, 'Hemispheres'));
    hemiareasDir = path_check(subdir(epDir, 'Hemispheres_Areas'));

    cases = define_cases(inDir);
    [Subjects, sub_types, nSUB, nFirst, nSecond] = ...
        define_sub_types(subFile);
    av_functions = {@asymmetry_av, @total_av, @global_av, @areas_av, ...
        @hemispheres_av, @hemiareas_av};
    n_functions = {@asymmetry, @total, @globality, @areas, ...
        @hemispheres, @hemiareas};
    av_paths = {asyDir, totDir, globDir, areasDir, hemiDir, hemiareasDir};
    ntypes = length(av_paths);
    locFLAG = 0;
    
    
    % setup
    [measure, ~, locations, chanlocs] = ...
        load_data(strcat(inDir, cases(1).name));
    aux_loc_file = strcat(path_check(inDir), 'Locations.mat');
    if isempty(locations) 
        if not(isempty(locations_file)) && check_loc_file(locations_file)
            locations = load_data(locations_file);
            locations = locations(:, 1);
        elseif exist(aux_loc_file, 'file')
            load(aux_loc_file);
        end
    end
    if isempty(locations)
        aux_locs = set_locations(inDir);
        if not(isempty(aux_locs))
            [r, c] = size(aux_locs);
            if r < c
                aux_locs = aux_locs';
            end
            locations = {};
            aux_locs = aux_locs(:, 1);
            for n_loc = 1:length(aux_locs)
                locations = [locations; aux_locs{n_loc}];
            end
            locations_file = strcat(inDir, 'Locations.mat');
            if exist(char_check(strcat(inDir, 'auxiliary.txt')), 'file')
                auxID = fopen(char_check(strcat(inDir, ...
                    'auxiliary.txt')), 'r');
                fseek(auxID, 0, 'bof');
                while ~feof(auxID)
                    proper = fgetl(auxID);
                    if contains(proper, 'Locations=')
                        locFLAG = 1;
                        break;
                    end
                end
                fclose(auxID); 
            end    
            if locFLAG == 1
                auxID = fopen('auxiliary.txt', 'a');
                fprintf(char_check(strcat('Locations=', locations_file)));
            end
            save(fullfile_check(locations_file), 'locations')
        end
    end
    
    if sum(strcmpi(type, Athena_measures_list(0, 1, 0, 0))) %aperiodic
        nLoc = size(measure, 2);
        nBands = 1;
        ind_ep = 1;
    elseif sum(strcmpi(type, Athena_measures_list(0, 0, 0, 1))) %power
        nLoc = size(measure, 3);
        nBands = size(measure, 1);
        ind_ep = 2;
    elseif sum(strcmpi(type, Athena_measures_list(0, 0, 1, 0))) %conn
        nLoc = size(measure, 3);
        nBands = size(measure, 1);
        ind_ep = 2;
        av_functions = {@asymmetry_conn_av, @total_conn_av, ...
            @global_conn_av, @areas_conn_av, @hemispheres_conn_av, ...
            @hemiareas_conn_av};
        n_functions = {@asymmetry_conn, @total_conn, @global_conn, ...
            @areas_conn, @hemispheres_conn, @hemiareas_conn};
    end 
    nEpochs = size(measure, ind_ep);
    setup_size = zeros(ntypes, 1);
    loc_av = [];
    loc_n = [];
    data_n.measure = measure;
    data_n.locations = locations;
    data.measure = squeeze(mean(measure, ind_ep));
    data.locations = locations;
    setup_data = {};
    directories = {epDir, asyDir, globDir, areasDir, totDir, hemiDir, ...
        hemiareasDir};
    for d = 1:length(directories)
        if not(exist(directories{d}, 'dir'))
            mkdir(directories{d})
        end
    end
    for j = 1:ntypes
        f_av = av_functions{j};
        if size(data.measure, 2) == 1
            data.measure = data.measure';
        end
        setup_data{j} = f_av(data);
        setup_size(j) = length(setup_data{j}.locations);  
        loc_av(j).First = zeros(nFirst, nBands, setup_size(j));
        loc_av(j).Second = zeros(nSecond, nBands, setup_size(j));
        loc_n(j).First = zeros(nFirst, nBands, nEpochs, setup_size(j));
        loc_n(j).Second = zeros(nSecond, nBands, nEpochs, setup_size(j));
    end
    
    
    countFirst = 1;
    countSecond = 1;
    waitbar(0, f, 'Computing temporal averages and spatial management')
    n_cases = length(cases);
    for i = 1:n_cases
        [measure, ~, locs, aux_chanlocs] = ...
            load_data(strcat(inDir, cases(i).name));
        if isempty(locs)
            if isempty(locations)
                locs = {};
                for n_loc = 1:size(measure, 3)
                    locs = [locs; char(string(n_loc))];
                end
            else
                locs = locations;
            end
        end
        data.measure = measure;
        data.locations = locs;
        data_n = data;
        data.measure = squeeze(mean(data.measure, ind_ep));
        for j = 1:ntypes
            check_type = not(isempty(loc_av(j).First)) || ...
                not(isempty(loc_av(j).Second));
            if check_type
                if size(data.measure, 2) == 1
                    data.measure = data.measure';
                end
                f_av = av_functions{j};
                f_n = n_functions{j};
                aux_data = data;
                aux_data_n = data_n;
                aux_data_n = f_n(aux_data_n);
                aux_data = f_av(aux_data);
                save(fullfile_check(strcat(epDir, cases(i).name)), 'data') 
                save(fullfile_check(strcat(av_paths{j}, cases(i).name)),...
                    'aux_data') 
                [ind, del_ind] = match_locations(...
                    setup_data{j}.locations, aux_data.locations);
                chanlocs = match_chanlocs(aux_chanlocs, chanlocs);
                if length(size(loc_av(j).First)) == 3
                    loc_av(j).First(:, :, del_ind) = [];
                    loc_av(j).Second(:, :, del_ind) = [];
                    loc_n(j).First(:, :, :, del_ind) = [];
                    loc_n(j).Second(:, :, :, del_ind) = [];
                else
                    loc_av(j).First(:, del_ind) = [];
                    loc_av(j).Second(:, del_ind) = [];
                    loc_n(j).First(:, :, del_ind) = [];
                    loc_n(j).Second(:, :, del_ind) = [];
                end
                setup_data{j}.locations(del_ind) = [];
                if length(size(aux_data.measure)) == 2 ...
                        && min(size(aux_data.measure)) ~= 1
                    aux_data.measure = aux_data.measure(:, ind);
                    aux_data_n.measure = aux_data_n.measure(:, :, ind);
                elseif nBands == 1
                    aux_data.measure = aux_data.measure(ind);
                    if length(size(aux_data_n.measure)) > 2
                        aux_data_n.measure = aux_data_n.measure(:, :, ind);
                    end
                end
            end
            for k = 1:nSUB
                aux_case = split(cases(i).name, '.');
                if contains(string(Subjects(k,1)), aux_case{1}) || ...
                    contains(cases(i).name, string(Subjects(k,1)))
                    if check_type
                        if length(size(aux_data.measure)) == 1 || ...
                                    min(size(aux_data.measure)) == 1
                            if patient_check(Subjects(k, end), ...
                                sub_types{1})
                                loc_av(j).First(countFirst, :) = ...
                                    aux_data.measure';
                                loc_n(j).First(countFirst, :, :, :) = ...
                                    aux_data_n.measure;
                                countFirst = countFirst+floor(j/ntypes);
                            else
                                loc_av(j).Second(countSecond, :) = ...
                                    aux_data.measure';
                                loc_n(j).Second(countSecond, :, :, :) = ...
                                    aux_data_n.measure;
                                countSecond = countSecond+floor(j/ntypes);
                            end
                        else
                            if patient_check(Subjects(k, end), ...
                                sub_types{1})
                                loc_av(j).First(countFirst, :, :) = ...
                                    aux_data.measure;
                                loc_n(j).First(countFirst, :, :, :) = ...
                                    aux_data_n.measure;
                                countFirst = countFirst+floor(j/ntypes);
                            else
                                loc_av(j).Second(countSecond, :, :) = ...
                                    aux_data.measure;
                                loc_n(j).Second(countSecond, :, :, :) = ...
                                    aux_data_n.measure;
                                countSecond = countSecond+floor(j/ntypes);
                            end
                        end
                    else
                        if patient_check(Subjects(k, end), sub_types{1})
                            countFirst = countFirst+floor(j/ntypes);
                        else
                            countSecond = countSecond+floor(j/ntypes);
                        end
                    end
                    break;
                end
            end
        end
        save(fullfile_check(strcat(epDir, cases(i).name)), 'data')
        waitbar(i/n_cases, f)
    end
     
    countFirst = countFirst-1;
    countSecond = countSecond-1;
    waitbar(1, f ,'Saving data')    
    for j = 1:ntypes
        First = struct();
        Second = struct();
    	First.data = matrix_management(loc_av(j).First, countFirst);
        Second.data = matrix_management(loc_av(j).Second, countSecond);
        First.locations = setup_data{j}.locations;
        Second.locations = setup_data{j}.locations;
        if j == 2
            locations = First.locations;
            save(fullfile_check(strcat(path_check(inDir), ...
                'Locations.mat')), 'locations')
        end
        save(fullfile_check(strcat(av_paths{j}, 'First.mat')), 'First')
        save(fullfile_check(strcat(av_paths{j}, 'Second.mat')), 'Second')
    end
    locations_file = strcat(path_check(limit_path(inDir, type)), ...
        'Locations.mat');
    if isempty(locations)
        locations = [];
    end
    
    for j = 1:ntypes
        First = struct();
        Second = struct();
    	First.data = matrix_management(loc_n(j).First, countFirst);
        Second.data = matrix_management(loc_n(j).Second, countSecond);
        First.locations = setup_data{j}.locations;
        Second.locations = setup_data{j}.locations;
        save(fullfile_check(strcat(av_paths{j}, 'First_ep.mat')), 'First')
        save(fullfile_check(strcat(av_paths{j}, 'Second_ep.mat')), 'Second')
    end
    locations_file = strcat(path_check(limit_path(inDir, type)), ...
        'Locations.mat');
    if isempty(locations)
        locations = [];
    end
    
    save(fullfile_check(locations_file), 'locations')
    
    chanlocs = sort_chanlocs(aux_chanlocs, locations);
    chanlocs_file = strcat(path_check(limit_path(inDir, type)), ...
        'Channel_locations.mat');
    if not(isempty(chanlocs))
        save(fullfile_check(chanlocs_file), 'chanlocs')
    end
    close(f)
end

%% check_loc_file
% This function checks if the locations file is valid.
%
% check = check_loc_file(locations_file)
%
% Input:
%   locations_file is the file which contains the locations
%
% Output:
%   check is 1 if the locations file is valid, 0 otherwise

function check = check_loc_file(locations_file)
    check = 0;
    null_list = {'[]', '0', 'nan', 'NaN', 'Nan', 'NAN', 'null', ...
        'NULL', 'Null', 'None', 'NONE', 'none', 'false', 'False'};
    for i = 1:length(null_list)
        if strcmp(null_list{i}, char_check(locations_file))
            check = 1;
        end
    end
    check = (check == 0);
end

%% set_locations
% This function is used to set the locations if they have not been used as
% input parameter in the main function.
%
% aux_locs = set_locations(inDir)
%
% Input:
%   inDir is the measure subdirectory
%   
% Output:
%   aux_locs is the list of locations

function aux_locs = set_locations(inDir)
    aux_path = split(path_check(inDir), filesep);
    aux_locations_file = '';
    msg = 'Do you want to use the locations file in the main directory of the study?';
    for p = 1:length(aux_path)-2
        aux_locations_file = strcat(aux_locations_file, aux_path{p},...
            filesep);
    end
    aux_locations_file = strcat(aux_locations_file, 'Locations.mat');
    if exist(aux_locations_file, 'file')
        if strcmpi(user_decision(msg, 'Locations file detected'), 'yes')
            aux_locs = load_data(aux_locations_file);
        else
            aux_locs = ask_locations();
        end
    else
        aux_locs = ask_locations();
    end
end


%% matrix_management
% This function is used to eliminate the not used rows from the data
% matrix.
%
% data = matrix_management(data, counter)
%
% Input:
%   data is the data matrix
%   counter is the actual number of subjects
%
% Output:
%   data is the managed data matrix


function data = matrix_management(data, counter)
    N = length(size(data));
    ind_str = 'data = data(1:counter';
    for i = 1:N-1
        ind_str = strcat(ind_str, ',:');
    end
    ind_str = strcat(ind_str, ');');
    
    eval(ind_str)
end