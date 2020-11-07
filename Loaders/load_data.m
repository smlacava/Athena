%% load_data
% This function is used to load the external data in the toolbox (time
% series, subjects file, locations file, etc.), in different formats (.mat,
% .edf, .xls').
%
% [data, fs, locs, chanlocs] = load_data(dataFile, locFLAG)
% 
% input:
%   dataFile is the data file to load (with his path)
%   locFLAG is the flag which has to be 1 if the user wants to manipulate
%       the names of the locations and to delete data relative to not
%       identified locations (0 or not defined otherwise)
%
% output:
%   data is the loaded data
%   fs is the sampling frequency obtained from the loaded file, it is empty
%       ([]) if it is not present in the data file
%   locs is a cell matrix which contains in the first column the names of
%       every location, it is empty ({}) if it is not present in the file
%   chanlocs is a structure which contains the names of the channels in the
%       labels field, and the related coordinates in the X, Y and Z fields
%       (it is an empty vector if it is not present in the data file)

function [data, fs, locs, chanlocs] = load_data(dataFile, locFLAG, ...
        varargin)
    [data_name, fs_name, loc_name, chanlocs_name] = ...
        check_parameters(varargin);
    fs = [];
    locs = {};
    chanlocs = [];
    if nargin == 1
        locFLAG = 0;
    end
    
    athenaFLAG = 0;
    avoid_locs = {'PHOTICPH', 'IBI', 'BURSTS', 'SUPPR', 'PHOTICREF'};
    avoid_locs_cont = {'DC', 'EKG'};
    loc_types = {'AF', 'FT', 'FC', 'FP', 'TP', 'CP', 'LO', 'SO', 'IO', ...
        'PO', 'CB', 'SP', 'O', 'T', 'F', 'C', 'A', 'P', 'M'};
    loc_others = {'Chin', 'NAS', 'Neck', 'RPA', 'LPA', 'ROC', 'LOC', ...
        'EMG'};
    loc_list = {};
    
    if contains(dataFile, '.mat')
        data = load(dataFile);
        split_file = split(dataFile, filesep);
        if isfield(data, 'conn') || isfield(data, 'Second') || ...
                isfield(data, 'First') || ...
                any(strcmpi(Athena_measures_list(), split_file{end-1}))
            athenaFLAG = 1;
        end
        data = struct2cell(data);
        data = data{1};
        if isstruct(data)
            if not(strcmp(fs_name, '')) && isfield(data, fs_name)
                fs = eval(strcat('data.', fs_name));
            elseif isfield(data, 'fs')
                fs = data.fs;
            elseif isfield(data, 'frequency')
                fs = data.frequency;
            elseif isfield(data, 'srate')
                fs = data.srate;
            end
            
            aux_chanlocs = [];
            if not(strcmp(chanlocs_name, '')) && isfield(data, ...
                    chanlocs_name)
                aux_chanlocs = eval(strcat('data.', chanlocs_name));
            elseif isfield(data, 'channels_locations')
            	aux_chanlocs = data.channels_locations;
            elseif isfield(data, 'chanlocs')
                aux_chanlocs = data.chanlocs;
            end
            
            if not(strcmp(loc_name, '')) && isfield(data, loc_name)
                locs = eval(strcat('data.', loc_name));
            elseif isfield(data, 'chanlocs')
                locs = data.chanlocs;
            elseif isfield(data, 'locs')
                locs = data.locs;
            elseif isfield(data, 'locations')
                locs = data.locations;
            elseif isfield(data, 'channels')
                locs = data.channels;
            elseif isfield(data, 'label')
                locs = data.label;
            elseif isfield(data, 'labels')
                locs = data.labels;
            end
            try
                locs = {locs.labels};
            catch
            end
            
            if not(isempty(aux_chanlocs))
                try
                    L = length(locs);
                    N = length(aux_chanlocs);
                    chanlocs = struct();
                    for i = 1:L
                        for j = 1:N
                            if strcmpi(locs{i}, aux_chanlocs(j).labels)
                                chanlocs(i).labels = ...
                                    aux_chanlocs(j).labels;
                                if isempty(aux_chanlocs(j).X)
                                    chanlocs(i).X = nan;
                                    chanlocs(i).Y = nan;
                                    chanlocs(i).Z = nan;
                                else
                                    chanlocs(i).X = aux_chanlocs(j).X;
                                    chanlocs(i).Y = aux_chanlocs(j).Y;
                                    chanlocs(i).Z = aux_chanlocs(j).Z;
                                end
                            end
                        end
                    end
                catch
                    chanlocs = [];
                end
            end
            
            if not(strcmp(data_name, '')) && isfield(data, data_name)
                data = eval(strcat('data.', data_name));
            elseif isfield(data, 'data')
                data = data.data;
            elseif isfield(data, 'EEG')
                data = data.EEG;
            elseif isfield(data, 'MEG')
                data = data.EEG;
            elseif isfield(data, 'time_series')
                data = data.time_series;
            else
                data = [];
            end
            
        end
        
    elseif contains(dataFile, '.xls')
        data = readxls(dataFile);
    elseif contains(dataFile, '.txt')
        data = readtxt(dataFile);
    elseif contains(dataFile, '.csv')
        data = readcsv(dataFile);
        
    elseif contains(dataFile, '.edf')
        [info, data] = edfread(dataFile);
        fs = info.frequency(1);
        locs = info.label;
    elseif contains(dataFile, '.eeg') || contains(dataFile, '.vhdr')
        [data, locs, fs] = readeeg(dataFile);
    end
    
    
    if locFLAG == 1 && not(isempty(locs))
        [r, c] = size(locs);
        if r < c
            locs = locs';
        end
        data(contains(locs, 'Annotations'), :) = [];
        locs(contains(locs, 'Annotations'), :) = [];
        if size(data, 1) > size(data, 2)
            data = data';
        end
        aux_locs = locs;
        aux_data = data;
        if not(isempty(locs))
            for i = 1:length(avoid_locs)
                locs_check = strcmpi(locs, avoid_locs{i});
                locs(locs_check == 1) = [];
                data(locs_check == 1, :) = [];
            end
            for i = 1:length(avoid_locs_cont)
                locs_check = contains(locs, avoid_locs_cont{i});
                locs(locs_check == 1) = [];
                data(locs_check == 1, :) = [];
            end
        
            nLoc_types = length(loc_types);
            nLoc = length(locs);
            for i = 1:nLoc_types
                for j = 1:nLoc
                    loc_list = [loc_list ...
                        char(strcat(loc_types{i}, string(j)))];
                end
                loc_list = [loc_list, char(strcat(loc_types{i}, 'Z')), ...
                    char(strcat(loc_types{i}, 'z'))];
            end
            loc_list = [loc_list, loc_others];
            nLoc_list = length(loc_list);
            aux = nLoc;
            for i = 1:nLoc
                if i > aux
                    break;
                end
                check = 0;
                for j = 1:nLoc_list
                    if contains(locs{i}, loc_list{j})
                        locs{i} = loc_list{j};
                        check = 1;
                        break;
                    end
                end
                if check == 0
                    locs(i) = [];
                    data(i, :) = [];
                    aux = aux-1;
                end
            end
        end
    
        if isempty(data)
            data = aux_data;
            locs = aux_locs;
        end
    
        if nargout == 3
            if size(data, 1) ~= size(locs)
                data = [];
                locs = [];
                chanlocs = [];
            end
        end
    end
    if isa(data, 'single')
        data = double(data);
    end
    
    dims = size(data);
    if athenaFLAG == 0 && length(dims) == 3
        data = reshape(data, [dims(1), dims(2)*dims(3)]);
    end
end


%% chack_parameters
% This function takes the parameters related to the optional name-value
% arguments of the load_data function.

function [data_name, fs_name, loc_name, chanlocs_name] = ...
    check_parameters(parameters)
    data_name = '';
    fs_name = '';
    loc_name = '';
    chanlocs_name = '';
    try
        parameters = parameters{:};
        for i = 1:length(parameters)
            if strcmpi(parameters{i}, 'data')
                data_name = parameters{i+1};
            elseif strcmpi(parameters{i}, 'fs')
                fs_name = parameters{i+1};
            elseif strcmpi(parameters{i}, 'locations')
                loc_name = parameters{i+1};
            elseif strcmpi(parameters{i}, 'channels_locations')
                chanlocs_name = parameters{i+1};
            end
        end
    catch
    end
end