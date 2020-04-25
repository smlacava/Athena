%% load_data
% This function is used to load the external data in the toolbox (time
% series, subjects file, locations file, etc.), in different formats (.mat,
% .edf, .xls').
%
% [data, fs, locs] = load_data(dataFile, locFLAG)
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

function [data, fs, locs] = load_data(dataFile, locFLAG)
    fs = [];
    locs = {};
    if nargin == 1
        locFLAG = 0;
    end
    
    avoid_locs = {'PHOTICPH', 'IBI', 'BURSTS', 'SUPPR', 'PHOTICREF'};
    avoid_locs_cont = {'DC', 'EKG'};
    loc_types = {'AF', 'FT', 'FC', 'FP', 'TP', 'CP', 'LO', 'SO', 'IO', ...
        'PO', 'CB', 'SP', 'O', 'T', 'F', 'C', 'A', 'P', 'M'};
    loc_others = {'Chin', 'NAS', 'Neck', 'RPA', 'LPA', 'ROC', 'LOC', ...
        'EMG'};
    loc_list = {};
    
    if contains(dataFile, '.mat')
        data = load(dataFile);
        data = struct2cell(data);
        data = data{1};
        if isstruct(data)
            if isfield(data, 'fs')
                fs = data.fs;
            elseif isfield(data, 'frequency')
                fs = data.frequency;
            elseif isfield(data, 'srate')
                fs = data.srate;
            end
            
            if isfield(data, 'chanlocs')
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
            
            if isfield(data, 'data')
                data = data.data;
            elseif isfield(data, 'EEG')
                data = data.EEG;
            elseif isfield(data, 'MEG')
                data = data.EEG;
            elseif isfield(data, 'time_series')
                data = data.time_series;
            end
            
        end
        
    elseif contains(dataFile, '.xlsx')
        data = readtable(dataFile, 'ReadVariableNames', false);
        data = table2cell(data);
        
    elseif contains(dataFile, '.edf')
        [info, data] = edfread(dataFile);
        fs = info.frequency(1);
        locs = info.label;
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
            end
        end
    end
    if isa(data, 'single')
        data = double(data);
    end
end
    
