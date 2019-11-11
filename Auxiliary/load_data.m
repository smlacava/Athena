%% load_data
% This function is used to load the external data in the toolbox (time
% series, subjects file, locations file, etc.), in different formats (.mat,
% .edf, .xls').
%
% [data, fs] = load_data(dataFile)
% 
% input:
%   dataFile is the data file to load (with his path)
%
% output:
%   data is the loaded data
%   fs is the sampling frequency obtained from the loaded file (optional)

function [data, fs] = load_data(dataFile)
    fs=[];
    if contains(dataFile, '.mat')
        data = load(dataFile);
        data = struct2cell(data);
        data = data{1};
    elseif contains(dataFile, '.xlsx')
        data = readtable(dataFile, 'ReadVariableNames', false);
        data = table2cell(data);
    elseif contains(dataFile, '.edf')
        [info, data] = edfread(dataFile);
        if nargout == 2
            fs = info.frequency(1);
        end
    end
end
    
