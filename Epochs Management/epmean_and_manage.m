%% epmean_and_manage
% This function computes the epochs mean of the data matrices and saves
% a single data matrix for the patients (PAT) and another one for the 
% healthy controls (HC)
% 
% epmean_and_manage(inDir, type, subFile)
%
% input:
%   inDir is the data directory 
%   type is the measure type (offset, plv, aec, etc.)
%   subFile is the file which contains the subjects list with their class
%
% output:
%   locations_file is the file of the locations, if they are not contained
%       inside each time series

function [locations_file] = epmean_and_manage(inDir, type, subFile)
    
    f = waitbar(0,'Initial setup process', ...
        'Color', '[0.67 0.98 0.92]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)

    type = string(type);
    inDir = path_check(inDir);
    epDir = subdir(inDir, 'Epmean');
    epDir = path_check(epDir);
    areasDir = path_check(subdir(epDir, 'Areas'));
    totDir = path_check(subdir(epDir, 'Total'));
    asyDir = path_check(subdir(epDir, 'Asymmetry'));
    globDir = path_check(subdir(epDir, 'Global'));
    locations_file = [];

    cases = define_cases(inDir);
    Subjects = load_data(subFile);
    nSUB = length(Subjects);
    nPAT = sum(double(Subjects(:, end)));
    nHC = nSUB-nPAT;
    av_functions = {@asymmetry_av, @total_av, @global_av, @areas_av};
    av_paths = {asyDir, totDir, globDir, areasDir};
    ntypes = length(av_paths);
    
    
    % setup
    [measure, ~, locations] = load_data(strcat(inDir, cases(1).name));
    aux_loc_file = strcat(path_check(inDir), 'Locations.mat');
    if isempty(locations) && exist(aux_loc_file, 'file')
        load(aux_loc_file);
    end
    if isempty(locations)
        aux_locs = ask_locations();
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
                locFLAG = 0;
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
            save(locations_file, 'locations')
        end
    end
    
    if sum(strcmp(type, ["offset"; "OFF"; "off"; "OFFSET"]))
        nLoc = size(measure, 2);
        nBands = 1;
        ind_ep = 2;
    elseif sum(strcmp(type, ["exponent"; "EXP"; "exp"; "EXPONENT"]))
        nLoc = size(measure,2);
        nBands = 1;
        ind_ep = 1;
    elseif sum(strcmp(type,["psd"; "PSD"; "psdr"; "PSDr"]))
        nLoc = size(measure, 3);
        nBands = size(measure, 1);
        ind_ep = 2;
    elseif sum(strcmp(type, ["pli"; "PLI"; "Pli"; "PLV"; "plv"; "Plv"; ...
            "AEC"; "AECo"; "AECc"; "aec"; "aecc"; "aeco"; "Aec"; ...
            "Aecc"; "Aeco"; "Conn"; "CONN"; "conn"]))
        nLoc = size(measure, 3);
        nBands = size(measure, 1);
        ind_ep = 2;
        av_functions = {@asymmetry_conn_av, @total_conn_av, ...
            @global_conn_av, @areas_conn_av};
    end 
    setup_size = zeros(ntypes, 1);
    loc_av = [];
    data.measure = squeeze(mean(measure, ind_ep));
    data.locations = locations;
    setup_data = {};
    for j = 1:ntypes
        f_av = av_functions{j};
        setup_data{j} = f_av(data);
        setup_size(j) = length(setup_data{j}.locations);  
        loc_av(j).PAT = zeros(nPAT, nBands, setup_size(j));
        loc_av(j).HC = zeros(nHC, nBands, setup_size(j));
    end
    
    
    countPAT = 1;
    countHC = 1;
    waitbar(0, f, 'Computing averages of signals')
    n_cases = length(cases);
    for i = 1:n_cases
        [measure, ~, locs] = load_data(strcat(inDir, cases(i).name));
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
        data.measure = squeeze(mean(data.measure, ind_ep));
        for j = 1:ntypes
            check_type = not(isempty(loc_av(j).PAT)) || ...
                not(isempty(loc_av(j).HC));
            if check_type
                aux_data = data;
                f_av = av_functions{j};
                aux_data = f_av(aux_data);
                save(strcat(epDir, cases(i).name), 'data') 
                save(strcat(av_paths{j}, cases(i).name), 'aux_data') 
                [ind, del_ind] = match_locations(...
                    setup_data{j}.locations, aux_data.locations);
                if length(size(loc_av(j).PAT)) == 3
                    loc_av(j).PAT(:, :, del_ind) = [];
                    loc_av(j).HC(:, :, del_ind) = [];
                else
                    loc_av(j).PAT(:, del_ind) = [];
                    loc_av(j).HC(:, del_ind) = [];
                end
                setup_data{j}.locations(del_ind) = [];
                if length(size(aux_data.measure)) == 2 ...
                        && min(size(aux_data.measure)) ~= 1
                    aux_data.measure = aux_data.measure(:, ind);
                elseif nBands == 1
                    aux_data.measure = aux_data.measure(ind);
                end
            end
            for k = 1:nSUB
                aux_case = split(cases(i).name, '.');
                if contains(string(Subjects(k,1)), aux_case{1}) || ...
                    contains(aux_case{1}, string(Subjects(k,1)))
                    if check_type
                        if length(size(aux_data.measure)) == 1 || ...
                                    min(size(aux_data.measure)) == 1
                            if patient_check(Subjects(k, end))
                                loc_av(j).PAT(countPAT, :) = ...
                                    aux_data.measure';
                                countPAT = countPAT+floor(j/ntypes);
                            else
                                loc_av(j).HC(countHC, :) = ...
                                    aux_data.measure';
                                countHC = countHC+floor(j/ntypes);
                            end
                        else
                            if patient_check(Subjects(k, end))
                                loc_av(j).PAT(countPAT, :, :) = ...
                                aux_data.measure;
                                countPAT = countPAT+floor(j/ntypes);
                            else
                                loc_av(j).HC(countHC, :, :) = ...
                                    aux_data.measure;
                                countHC = countHC+floor(j/ntypes);
                            end
                        end
                    else
                        if patient_check(Subjects(k, end))
                            countPAT = countPAT+floor(j/ntypes);
                        else
                            countHC = countHC+floor(j/ntypes);
                        end
                    end
                    break;
                end
            end
        end
        save(strcat(epDir, cases(i).name), 'data')
        waitbar(i/n_cases, f)
    end
     
    waitbar(1, f ,'Saving data')    
    for j = 1:ntypes
        PAT = struct();
        HC = struct();
    	PAT.data = loc_av(j).PAT;
        HC.data = loc_av(j).HC;
        PAT.locations = setup_data{j}.locations;
        HC.locations = setup_data{j}.locations;
        save(strcat(av_paths{j}, 'PAT.mat'), 'PAT')
        save(strcat(av_paths{j}, 'HC.mat'), 'HC')
    end
    close(f)
end