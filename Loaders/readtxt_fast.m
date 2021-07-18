%% readtxt
% This function reads a time series by a txt file
%
% data = readtxt(dataFile)
%
% input:
%   dataFile is the name of the file (with its path)
%
% output:
%   data is the data matrix


function data = readtxt_fast(dataFile)
    auxID = fopen(dataFile, 'r');
    fseek(auxID, 0, 'bof');
    line = fgetl(auxID);
    aux_line = split(line, ' ');
    aux_data = [];
    for i = 1:length(aux_line)
        try
            aux_data(1, i) = str2double(aux_line{i});
        catch
            break;
        end
    end
    N = length(aux_data);
    sp = repmat("%f", 1, N);
    fseek(auxID, 0, 'bof');
    if contains(line, ',')
        delimiter = ',';
    else
        delimiter = " ";
    end
    spec = strjoin(sp);
    data_cell = textscan(auxID, spec, 'Delimiter', delimiter, ...
        'TreatAsEmpty', {'NA','na'}, 'CollectOutput', 1, 'HeaderLines', 0);
    data = data_cell{1};
    
    fclose(auxID);
    if size(data, 1) > size(data, 2)
        data = data';
    end
    if sum(data(:, 1) == [1:size(data, 1)]') == size(data, 1)
        data(:, 1) = [];
    end
end