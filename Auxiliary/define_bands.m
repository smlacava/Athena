%% define_bands
% This function is used in order to define the ranges of the frequency
% bands
%
% bands = define_bands(dataPath, bands, backFLAG)
%
% Input:
%   dataPath is the directory in which has to be searched the auxiliary
%       file (the directory related to the single measure)
%   bands is the number of frequency bands
%   backFLAG has to be 1 if the measure is a background measure (offset or
%       exponent), 0 otherwise (0 by default)
%
% Output:
%   bands is the list of frequency bands, if the file is present inside the
%       indicated directory (the number of bands otherwise)

function bands = define_bands(dataPath, bands, backFLAG)
    if nargin < 3
        backFLAG = 0;
    end
    
    dataFile = strcat(dataPath, 'auxiliary.txt');
    if not(exist(dataFile, 'file'))
        dataFile = strcat(path_check(limit_path(dataPath, 'Network')), ...
            'auxiliary.txt');
    end
    
    if backFLAG == 1
        parameters = read_file(dataFile);
        cf = search_parameter(parameters, 'cf');
        if not(isempty(cf)) 
            bands = {strcat(string(cf(1)), '-', string(cf(end)), " Hz")};
        end
        return;
    end
    
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