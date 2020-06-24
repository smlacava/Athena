%% define_bands
% This function is used in order to define the ranges of the frequency
% bands
%
% bands = define_bands(dataPath, bands)
%
% Input:
%   dataPath is the directory in which has to be searched the auxiliary
%       file (the directory related to the single measure)
%   bands is the number of frequency bands
%
% Output:
%   bands is the list of frequency bands, if the file is present inside the
%       indicated directory (the number of bands otherwise)

function bands = define_bands(dataPath, bands)
    dataFile = strcat(dataPath, 'Auxiliary.txt');
    if exist(dataFile, 'file')
        parameters = read_file(dataFile);
        cf = search_parameter(parameters, 'cf');
        if not(isempty(cf)) 
            bands = {};
            for i = 1:length(cf)-1
                bands = [bands strcat(string(cf(i)), '-', ...
                    string(cf(i+1)), " Hz")];
            end
        end
    end
end