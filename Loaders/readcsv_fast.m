%% readcsv_fast
% This function reads a time series by a csv file in a faster way than the
% older function.
%
% data = readcsv_fast(dataFile)
%
% input:
%   dataFile is the name of the file (with its path)
%
% output:
%   data is the data matrix


function data = readcsv_fast(dataFile)
    T = readtable(dataFile);
    try
        data = table2array(T);
    catch
        data = table2array(T(:, 2:end)); %If uses indexes as first column
    end
    if size(data, 1) > size(data, 2)
        data = data';
    end
    if sum(data(:, 1) == [1:size(data, 1)]') == size(data, 1)
        data(:, 1) = [];
    end
end
                
                