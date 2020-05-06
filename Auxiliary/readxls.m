%% readxls
% This function reads a time series by a xls or an xlsx file
%
% data = readxsl(dataFile)
%
% input:
%   dataFile is the name of the file (with its path)
%
% output:
%   data is the data matrix


function data = readxls(dataFile)
    data = xlsread(dataFile);
    if size(data, 1) > size(data, 2)
        data = data';
    end
    if sum(data(:, 1) == [1:size(data, 1)]') == size(data, 1)
        data(:, 1) = [];
    end
end