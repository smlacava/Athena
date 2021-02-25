%% network_measure
% This function computes a network measure on a the connectivity matrix for
% all subjects, considering the adjacency matrix as the average of the
% connectivity matrix between the epochs.
%
% network_measure(dataPath, measure, network_measure, loc_file, ...
%       subFile, normFLAG)
%
% Input:
%   dataPath is the main folder of the study
%   measure is the analyzed connectivity measure
%   network_measure is the name of network metrics to analyze
%   loc_file is the name of the file (with its path) which contains the
%       list of common locations (optional, the the file Location.mat
%       computed by Athena inside the measure directory by default and if
%       it is an empty vector)
%   subFile is the name of the file which contains the subjects list with 
%       their belonging class (use an empty vector as value for this
%       parameter to avoid grouping, and in this case all the subjects will 
%       be considered as belonging to the same group, [] by default)
%   normFLAG has to be 1 in order to normalize the network measure vector
%       through the minmax normalization, it is also possible to specify 
%       instead the normalization type between 'minmax', 'zscore' and
%       'max', while it is possible to use 0 or 'none' to avoid
%       normalization (1, or 'minmax' equivalently, by defalult)


function network_measure(dataPath, measure, network_measure, loc_file, ...
    subFile, normFLAG)

    f = waitbar(0,'Processing your data', 'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    if nargin < 4
        loc_file = [];
    end
    inDir = identify_directory(dataPath, measure);
    cases = define_cases(inDir);
    if nargin < 5 || isempty(subFile)
        nSUB = length(cases);
        nFirst = nSUB;
        nSecond = 0;
        Subjects = [];
        for i = 1:length(cases)
            Subjects = [Subjects; strtok(cases(i).name, '.'), "0"];
        end
        sub_types = {'0'; '1'};
    else
        [Subjects, sub_types, nSUB, nFirst, nSecond] = ...
            define_sub_types(subFile);
    end
    if nargin < 6
        normFLAG = 'minmax';
    end
    
    if not(ischar(normFLAG))
        normFLAG = 'none';
    end 
    
    network_metrics = {'betweenness_centrality', ...
        'closeness_centrality', 'clustering_coefficient', ...
        'eigenvector_centrality', 'generank_centrality', ...
        'katz_centrality', 'strength', 'subgraph_centrality', ...
        'MST_degree'};
    network_names = {'Betweenness Centrality', ...
        'Closeness Centrality', 'Clustering Coefficient', ...
        'Eigenvector Centrality', 'Generank Centrality', ...
        'Katz Centrality', 'Strength', 'Subgraph Centrality', ...
        'MST Degree'};
    functions = {@betweenness_centrality, ...
        @closeness_centrality, @clustering_coefficient, ...
        @eigenvector_centrality, @generank_centrality, ...
        @katz_centrality, @strength, @subgraph_centrality, @mst_degree};
    network_function = functions(strcmpi(network_measure, network_metrics));
    network_function = network_function{1};
    network = network_names(strcmpi(network_measure, network_metrics));
    network = network{1};
    
    dataPath = path_check(strcat(path_check(dataPath), measure));
    outDir = path_check(strcat(path_check(strcat(path_check(dataPath), ...
        'Network')), network));
    bands_list = define_bands(dataPath, {});
    nBands = length(bands_list);
    
    if isempty(loc_file)
        loc_file = strcat(dataPath, 'Locations.mat');
    end
    if not(exist(loc_file, 'file'))
        error('Locations file not found')
    end
    locations = load_data(loc_file);
    
    create_directory(outDir);
    globDir = strcat(path_check(outDir), 'Global', filesep);
    totDir = strcat(path_check(outDir), 'Total', filesep);
    asyDir = strcat(path_check(outDir), 'Asymmetry', filesep);
    areasDir = strcat(path_check(outDir), 'Areas', filesep);
    hemiDir = strcat(path_check(outDir), 'Hemispheres', filesep);
    hemiareasDir = strcat(path_check(outDir), 'Hemispheres_Areas', filesep);
    create_directory(globDir);
    create_directory(totDir);
    create_directory(asyDir);
    create_directory(areasDir);
    create_directory(hemiDir);
    create_directory(hemiareasDir);
   
    network_data = struct();
    countFirst = 1;
    countSecond = 1;
    for i = 1:length(cases)
        load(fullfile_check(strcat(inDir, cases(i).name)));
        for band = 1:nBands
            aux_data = data_management(data, locations, band, bands_list);
            if i == 1 && band == 1
                network_data.measure = zeros(nBands, length(aux_data));
            end
            network_data.measure(band, :) = value_normalization(...
                network_function(aux_data, 0)', normFLAG);
            
        end
        network_data.locations = locations;
        save(fullfile_check(strcat(outDir, cases(i).name)), 'network_data')
        
        if i == 1
            [globFirst, globSecond, asyFirst, asySecond, ...
                areasFirst, areasSecond, totFirst, totSecond, ...
                hemiFirst, hemiSecond, hemiareasFirst, hemiareasSecond, ...
                areas, total, hemispheres, hemiareas] = ...
                groups_initialization(network_data, nFirst, nSecond, nBands);
        end
        
        aux_data = global_av(network_data);
        [globFirst, globSecond, ~, ~] = group_assignment(aux_data, ...
            globFirst, globSecond, countFirst, countSecond, Subjects, ...
            sub_types{1}, cases(i).name);
        save(fullfile_check(strcat(globDir, cases(i).name)), 'aux_data');
        
        aux_data = total_av(network_data);
        [totFirst, totSecond, ~, ~] = group_assignment(aux_data, ...
            totFirst, totSecond, countFirst, countSecond, Subjects, ...
            sub_types{1}, cases(i).name);
        save(fullfile_check(strcat(totDir, cases(i).name)), 'aux_data');
        
        aux_data = areas_av(network_data);
        [areasFirst, areasSecond, ~, ~] = group_assignment(aux_data, ...
            areasFirst, areasSecond, countFirst, countSecond, Subjects, ...
            sub_types{1}, cases(i).name);
        save(fullfile_check(strcat(areasDir, cases(i).name)), 'aux_data');
        
        aux_data = asymmetry_av(network_data);
        [asyFirst, asySecond, countFirst, countSecond] = ...
            group_assignment(aux_data, asyFirst, asySecond, countFirst, ...
            countSecond, Subjects, sub_types{1}, cases(i).name);
        save(fullfile_check(strcat(asyDir, cases(i).name)), 'aux_data');
        
        aux_data = hemiareas_av(network_data);
        [hemiareasFirst, hemiareasSecond, ~, ~] = ...
            group_assignment(aux_data, hemiareasFirst, hemiareasSecond, ...
            countFirst, countSecond, Subjects, sub_types{1}, ...
            cases(i).name);
        save(fullfile_check(strcat(hemiareasDir, cases(i).name)), ...
            'aux_data');
        
        aux_data = hemispheres_av(network_data);
        [hemiFirst, hemiSecond, ~, ~] = group_assignment(aux_data, ...
            hemiFirst, hemiSecond, countFirst, countSecond, Subjects, ...
            sub_types{1}, cases(i).name);
        save(fullfile_check(strcat(hemiDir, cases(i).name)), 'aux_data');
        
        waitbar(i/length(cases), f)
    end
    
    save_groups(globFirst, globSecond, asyFirst, asySecond, areasFirst, ...
        areasSecond, totFirst, totSecond, hemiFirst, hemiSecond, ...
        hemiareasFirst, hemiareasSecond, areas, total, hemispheres, ...
        hemiareas, globDir, asyDir, areasDir, totDir, hemiDir, ...
        hemiareasDir);
    close(f)
end


%% data_management
% This function manages the connectivity matrix in order to consider the
% only common locations for all the subjects, averaging between the
% epochs, and finally considering the analyzed frequency band.
%
% data = data_management(conn, locations, band, bands_list)
%
% Input:
%   conn is the structure which contains the data matrix and the locations
%       related to a single subject
%   locations is the list of locations to analyze (which have to be in
%       common with all the subjects)
%   band is the number of frequency band to analyze
%   bands_list is the list of the frequency bands on which the connectivity
%       measure is computed
%
% Output:
%   data is the (locations x locations) managed data matrix


function data = data_management(conn, locations, band, bands_list)
    if length(size(conn.measure)) == 4
        data = squeeze(conn.measure(band, :, :, :));
        if length(size(data)) > 2
            data = squeeze(mean(data, 1));
        end
    elseif length(bands_list) > 1
        data = squeeze(conn.measure(band, :, :));
    elseif length(size(conn.measure)) == 3
        data = squeeze(mean(conn.measure, 1));
    else
        data = conn.measure;
    end
    if isempty(conn.locations)
        return;
    end
    aux_locations = conn.locations;
    del_ind = [];
    for j = 1:length(aux_locations)
        bool_loc = strcmpi(aux_locations{j}, locations);
        if sum(bool_loc) == 0
            del_ind = [del_ind, j];
        end
    end
    data(del_ind, :) = [];
    data(:, del_ind) = [];
    aux_locations(del_ind) = [];
    NLoc = length(locations);
    idx = zeros(NLoc, 1);
    for j = 1:NLoc
        for i = 1:NLoc
            if strcmpi(aux_locations{j}, locations{i})
                idx(j) = i;
            end
        end
    end
    data = data(idx, :);
    data = data(:, idx);
end    


%% identify_directory
% This function check if the measure subfolder contains the Epmean folder,
% and in this case use it to compute the network metrix, otherwise it uses
% the raw measures.
%
% dataPath = identify_directory(dataPath, measure)
%
% Input:
%   dataPath is the main folder of the study
%   measure is the name of the connectivity measure
%
% Output:
%   dataPath is the folder from which extract data


function dataPath = identify_directory(dataPath, measure)
    dataPath = path_check(strcat(path_check(dataPath), measure));
    if exist(strcat(dataPath, 'Epmean'), 'dir')
        dataPath = strcat(dataPath, 'Epmean', filesep);
    end
end


%% groups_initialization
% This function initialize the groups matrices.
%
% [globFirst, globSecond, asyFirst, asySecond, areasFirst, areasSecond, ...
%    totFirst, totSecond] = groups_initialization(network_data, nFirst, ...
%    nSecond, nBands)
%
% Input:
%   network_data is the network measure related to a subject
%   nFirst is the number of subjects belonging to the first group
%   nSecond is the number of subjects belonging to the second group
%   nBands is the number of analyzed frequency bands
%
% Output:
%   globFirst is the 0s matrix related to the first group of subjects in
%       the global area
%   globSecond is the 0s matrix related to the second group of subjects in
%       the global area
%   asyFirst is the 0s matrix related to the first group of subjects in the
%       asymmetry
%   asySecond is the 0s matrix related to the second group of subjects in
%       the asymmetry
%   areasFirst is the 0s matrix related to the first group of subjects in
%       the single macroareas
%   areasSecond is the 0s matrix related to the second group of subjects in
%       the single macroareas
%   totFirst is the 0s matrix related to the first group of subjects in the
%       single locations
%   totSecond is the 0s matrix related to the second group of subjects in
%       the single locations
%   hemiFirst is the 0s matrix related to the first group of subjects in
%       the single hemispheres
%   hemiSecond is the 0s matrix related to the second group of subjects in
%       the single hemispheres
%   hemiareasFirst is the 0s matrix related to the first group of subjects
%       in the single areas in the single hemispheres
%   hemiareasSecond is the 0s matrix related to the second group of
%       subjects in the single areas in the single hemispheres


function [globFirst, globSecond, asyFirst, asySecond, areasFirst, ...
    areasSecond, totFirst, totSecond, hemiFirst, hemiSecond, ...
    hemiareasFirst, hemiareasSecond, areas, total, hemispheres, ...
    hemiareas] = groups_initialization(network_data, nFirst, nSecond, ...
    nBands)
    
    areas_data = areas_av(network_data);
    hemi_data = hemispheres_av(network_data);
    hemiareas_data = hemiareas_av(network_data);
    
    areas = areas_data.locations;
    total = network_data.locations;
    hemispheres = hemi_data.locations;
    hemiareas = hemiareas_data.locations;
    
	globFirst = zeros(nFirst, nBands);
    globSecond = zeros(nSecond, nBands);
    asyFirst = zeros(nFirst, nBands);
    asySecond = zeros(nSecond, nBands);
    areasFirst = zeros(nFirst, nBands, length(areas_data.locations));
    areasSecond = zeros(nSecond, nBands, length(areas_data.locations));
    totFirst = zeros(nFirst, nBands, length(network_data.locations));
    totSecond = zeros(nSecond, nBands, length(network_data.locations));
    hemiFirst = zeros(nFirst, nBands, length(hemi_data.locations));
    hemiSecond = zeros(nSecond, nBands, length(hemi_data.locations));
    hemiareasFirst = zeros(nFirst, nBands, ...
        length(hemiareas_data.locations));
    hemiareasSecond = zeros(nSecond, nBands, ...
        length(hemiareas_data.locations));
    
end

%% group_assignment
% This function assign the subject to the belonging group.
%
% [First, Second, countFirst, countSecond] = group_assignment(aux_data, ...
%       First, Second, countFirst, countSecond, Subjects, sub_type, name)
%
% Input:
%   aux_data is the data structure related to a subject to insert
%   First is the matrix related to the first group of subjects
%   Second is the matrix related to the second group of subjects
%   countFirst is the index of the first non-updated first group subject
%   countSecond is the index of the first non-updated second group subject
%   Subjects is the matrix which contains the list of subjects on the first
%       column and the belonging class on the last one
%   sub_type is the name of the first group of subjects
%   name is the name of the subject to insert
%
% Output:
%   First is the updated matrix related to the first group of subjects
%   Second is the updated matrix related to the second group of subjects
%   countFirst is the index of the following non-updated first group 
%       subject
%   countSecond is the index of the following non-updated second group 
%       subject

function [First, Second, countFirst, countSecond] = ...
    group_assignment(aux_data, First, Second, countFirst, countSecond, ...
    Subjects, sub_type, name)

    for k = 1:length(Subjects)
        try
            sub_test = contains(strtok(name, '.'), string(Subjects(k)));
        catch
            sub_test = contains(strtok(name, '.'), Subjects{k});
        end
        if sub_test == 1
            break;
        end
    end

    dim = length(size(aux_data.measure));
    
    if patient_check(Subjects(k, end), sub_type)
        if dim == 2
            First(countFirst, :, :) = aux_data.measure;
        elseif dim == 3
            First(countFirst, :, :, :) = aux_data.measure;
        end
        countFirst = countFirst+1;
    else
        if dim == 2
            Second(countSecond, :, :) = aux_data.measure;
        elseif dim == 3
            Second(countSecond, :, :, :) = aux_data.measure;
        end
        countSecond = countSecond+1;
    end
end


%% save_groups
% This function saves the network measures computed on the single spatial 
% subdivisions, grouped per subject classes.
%
% save_groups(globFirst, globSecond, asyFirst, asySecond, areasFirst, ...
%    areasSecond, totFirst, totSecond, areas, total, globDir, asyDir, ...
%    areasDir, totDir)
%
% Input:
%   globFirst is the matrix related to the first group in the global area
%   globSecond is the matrix related to the second group in the global area
%   asyFirst is the matrix related to the first group in the asymmetry
%   asySecond is the matrix related to the second group in the asymmetry
%   areasFirst is the matrix related to the first group in the single
%       macroareas
%   areasSecond is the matrix related to the second group in the single
%       macroareas
%   totFirst is the matrix related to the first group in the single
%       locations
%   totSecond is the matrix related to the second group in the single
%       locations
%   areas is the list of macroareas
%   total is the list of the single locations
%   globDir is the output directory related to the global analysis
%   asyDir is the output directory related to the asymmetry analysis
%   areasDir is the output directory related to the macroareas analysis
%   totDir is the output directory related to the single locations analysis


function save_groups(globFirst, globSecond, asyFirst, asySecond, ...
    areasFirst, areasSecond, totFirst, totSecond, hemiFirst, ...
    hemiSecond, hemiareasFirst, hemiareasSecond, areas, total, ...
    hemispheres, hemiareas, globDir, asyDir, areasDir, totDir, hemiDir, ...
    hemiareasDir)
    
    First = struct();
    Second = struct();
    First.data = globFirst;
    Second.data = globSecond;
    First.locations = "global";
    Second.locations = "global";
    save(fullfile_check(strcat(globDir, 'First.mat')), 'First')
    save(fullfile_check(strcat(globDir, 'Second.mat')), 'Second')
    
    First = struct();
    Second = struct();
    First.data = totFirst;
    Second.data = totSecond;
    First.locations = total;
    Second.locations = total;
    save(fullfile_check(strcat(totDir, 'First.mat')), 'First')
    save(fullfile_check(strcat(totDir, 'Second.mat')), 'Second')
    
    First = struct();
    Second = struct();
    First.data = asyFirst;
    Second.data = asySecond;
    First.locations = "asymmetry";
    Second.locations = "asymmetry";
    save(fullfile_check(strcat(asyDir, 'First.mat')), 'First')
    save(fullfile_check(strcat(asyDir, 'Second.mat')), 'Second')
    
    First = struct();
    Second = struct();
    First.data = areasFirst;
    Second.data = areasSecond;
    First.locations = areas;
    Second.locations = areas;
    save(fullfile_check(strcat(areasDir, 'First.mat')), 'First')
    save(fullfile_check(strcat(areasDir, 'Second.mat')), 'Second')
    
    First = struct();
    Second = struct();
    First.data = hemiareasFirst;
    Second.data = hemiareasSecond;
    First.locations = hemiareas;
    Second.locations = hemiareas;
    save(fullfile_check(strcat(hemiareasDir, 'First.mat')), 'First')
    save(fullfile_check(strcat(hemiareasDir, 'Second.mat')), 'Second')
    
    First = struct();
    Second = struct();
    First.data = hemiFirst;
    Second.data = hemiSecond;
    First.locations = hemispheres;
    Second.locations = hemispheres;
    save(fullfile_check(strcat(hemiDir, 'First.mat')), 'First')
    save(fullfile_check(strcat(hemiDir, 'Second.mat')), 'Second')
end
    