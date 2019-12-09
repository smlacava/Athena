%% load_data
% This function is used to load the external data in the toolbox (time
% series, subjects file, locations file, etc.), in different formats (.mat,
% .edf, .xls').
%
% [data, fs, locs] = load_data(dataFile)
% 
% input:
%   dataFile is the data file to load (with his path)
%
% output:
%   data is the loaded data
%   fs is the sampling frequency obtained from the loaded file, it is empty
%       ([]) if it is not present in the data file
%   locs is a cell matrix which contains in the first column the names of
%       every location, it is empty ({}) if it is not present in the file

function [data, fs, locs] = load_data(dataFile)
    fs = [];
    locs = {};
    
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
    
    data(contains(locs, 'Annotations'),:)=[];
    [r, c] = size(locs);
    if r < c
    	locs = locs';
    end
    locs(contains(locs, 'Annotations'),:)=[];
end
    
