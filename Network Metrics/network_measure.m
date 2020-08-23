%% network_measure
% This function computes a network measure on a the connectivity matrix for
% all subjects, considering the adjacency matrix as the average of the
% connectivity matrix between the epochs.
%
% network_measure(dataPath, measure, network_measure, band, locations_file)
%
% Input:
%   dataPath is the main folder of the study
%   measure is the analyzed connectivity measure
%   network_measure is the name of network metrics to analyze
%   band is the number of frequency band to analyze
%   locations_file is the name of the file (with its path) which contains
%       the list of common locations (optional, the the file Location.mat
%       computed by Athena inside the measure directory by default and if
%       it is an empty vector)


function network_measure(dataPath, measure, network_measure, band, ...
    locations_file)
    
    if nargin < 5
        locations_file = [];
    end
    
    dataPath = path_check(strcat(path_check(dataPath), measure));
    bands_list = define_bands(dataPath, {});
    band_name = bands_list(band);
    
    network_metrics = {'betweenness_centrality', ...
        'closeness_centrality', 'clustering_coefficient', ...
        'eigenvector_centrality', 'generank_centrality', ...
        'katz_centrality', 'strength', 'subgraph_centrality'};
    network_names = {'Betweenness Centrality', ...
        'Closeness Centrality', 'Clustering Coefficient', ...
        'Eigenvector Centrality', 'Generank Centrality', ...
        'Katz Centrality', 'Strength', 'Subgraph Centrality'};
    functions = {@betweenness_centrality, ...
        @closeness_centrality, @clustering_coefficient, ...
        @eigenvector_centrality, @generank_centrality, ...
        @katz_centrality, @strength, @subgrap_centrality};
    network_function = functions(strcmpi(network_measure, network_metrics));
    network_function = network_function{1};
    network = network_names(strcmpi(network_measure, network_metrics));
    network = network{1};
    
    if isempty(locations_file)
        locations_file = strcat(dataPath, 'Locations.mat');
    end
    if not(exist(locations_file, 'file'))
        error('Locations file not found')
    end
    locations = load_data(locations_file);
    
    cases = define_cases(dataPath);
    outDir = path_check(strcat(path_check(strcat(path_check(dataPath), ...
        'Network')), network));
    create_directory(outDir);
    for i = 1:length(cases)
        load(strcat(dataPath, cases(i).name));
        data = data_management(conn, locations, band, bands_list);
        network_data = network_function(data);
        save(strcat(outDir, band_name, cases(i).name), ....
            'network_data')
    end
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
    if length(size(conn.data)) == 4
        data = squeeze(conn.data(band, :, :, :));
        if length(size(data)) > 2
            data = squeeze(mean(data, 1));
        end
    elseif length(bands_list) > 1
        data = squeeze(conn.data(band, :, :));
    elseif length(size(conn.data)) == 3
        data = squeeze(mean(conn.data, 1));
    else
        data = conn.data;
    end
    if isempty(conn.locations)
        return;
    end
    aux_locations = conn.locations;
    del_ind = [];
    for j = 1:length(aux_locations)
        if sum(strcmpi(aux_locations{j}, locations)) == 0
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