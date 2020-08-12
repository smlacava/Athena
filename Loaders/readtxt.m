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


function data = readtxt(dataFile)
    auxID = fopen(dataFile, 'r');
    fseek(auxID, 0, 'bof');
    data = [];
    aux_data = [];
    while ~feof(auxID)
        line = fgetl(auxID);
        aux_line = split(line, ' ');
        for i = 1:length(aux_line)
            try
                aux_data(1, i) = str2double(aux_line{i});
            catch
                break;
            end
        end
        try
            data = [data; aux_data];
        catch
            break;
        end
    end
    fclose(auxID);
    if size(data, 1) > size(data, 2)
        data = data';
    end
    if sum(data(:, 1) == [1:size(data, 1)]') == size(data, 1)
        data(:, 1) = [];
    end
end