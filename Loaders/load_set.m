%% load_set
% This function loads a recording in the eeglab standard format, selecting
% the aimed .set file, which has to be in a folder which also contain the
% .fdt file.
%
% EEG = load_set(filename)
%
% Input
%   filename is the name of the file, with the related path, in .set
%       extension, which contains information about the recording
%
% Output:
%   EEG is the structure containing the recording, as value of the data
%       field, and other related informations

function EEG = load_set(filename)
    aux = load('-mat', filename);
    if isfield(aux, 'EEG')
        EEG = aux.EEG;
    else
        EEG = aux;
    end
    [EEG.filepath, EEG.filename, ~] = fileparts(filename);
    EEG.filename = [EEG.filename '.fdt'];
    [~, EEG.data, ext] = fileparts(EEG.data); 
    
    fdt_filename = strcat(path_check(EEG.filepath), EEG.data, ext);
    if ischar(EEG.data)
        if exist(fdt_filename, 'file')
            fid = fopen(fdt_filename, 'r', 'ieee-le');
        else
            fdt_filename = strcat(strtok(filename, '.'), '.fdt');
            fid = fopen(fdt_filename, 'r', 'ieee-le');
        end
        EEG.data = fread(fid, [EEG.nbchan Inf], 'float32');
    end
end