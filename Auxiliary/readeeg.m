%% readeeg
% This function reads a time series by a eeg file
%
% data = readeeg(dataFile)
%
% input:
%   dataFile is the name of the file (with its path)
%
% output:
%   data is the data structure


function [data, locations, fs] = readeeg(dataFile)  
    LASTN = maxNumCompThreads(max(floor(maxNumCompThreads*0.25), 1));
	[inDir, fileName] = fileparts(dataFile);
	[fs, locations, info] = readheader(strcat(path_check(inDir), ...
        fileName, '.vhdr'));
    nLoc = length(locations);

    if exist(fullfile(inDir, info.eegFile), 'file')
        eegFile = fullfile(inDir, info.eegFile);
    elseif exist(fullfile(inDir, lower(info.eegFile)), 'file')
        eegFile = fullfile(inDir, lower(info.eegFile));
    end
    
    format_bytes = 2;
    switch lower(info.DataType)
        case 'int_16'        
            binformat = 'int16'; 
        case 'uint_16'       
            binformat = 'uint16'; 
        case 'ieee_float_32'
            binformat = 'float32'; 
            format_bytes = 4;
        otherwise
            return
    end

    aux = fopen(eegFile,'r');
    fseek(aux, 0, 'eof');
    totBytes =  ftell(aux);
    nFrames =  totBytes/(format_bytes*nLoc);

    fseek(aux, 0, 'bof');              
    data = fread(aux, [nLoc, nFrames], [binformat '=>double']);
    fclose(aux);
    data = data.*repmat(info.scaleFactor', 1 ,size(data, 2));
    maxNumCompThreads(LASTN);
end


function [fs, locations, info] = readheader(headerFile)
	aux_h = fopen(headerFile);
    data = {};
    while ~feof(aux_h)
        data = [data; {fgetl(aux_h)}];
    end
    fclose(aux_h);
    
    data(strncmp(';', data, 1)) = [];
    data(cellfun('isempty', data) == true) = [];
    nData = length(data);
    aux_data = 1:nData;
    sections = [aux_data(1, strncmp('[', data, 1) == 1), nData+1];
    nSections = length(sections)-1;
    hdr = struct();
    hdr.channelinfos = [];
    for s = 1:nSections
        fieldname = split(data{sections(s)}, '[');
        fieldname = split(fieldname{2}, ']');
        fieldname = lower(fieldname{1});
        fieldname(isspace(fieldname) == true) = [];
        switch fieldname
            case {'commoninfos' 'binaryinfos'}
                for line = sections(s)+1:sections(s+1)-1
                    aux_line = split(data{line}, '=');
                    parameter = aux_line{1};
                    value = aux_line{2};
                    eval(strcat('hdr.', fieldname, '.', parameter, ...
                        '=value;'));
                end
            case {'channelinfos' 'coordinates' 'markerinfos'}
                for line = sections(s)+1:sections(s+1)-1
                    aux_line = split(data{line}, '=');
                    parameter = aux_line{1};
                    parameter = parameter(3:end);
                    value = aux_line{2};
                    eval(strcat('hdr.', fieldname, '{', parameter, ...
                        '}=value;'));
                end
            case 'comment'
                eval(strcat('hdr.', fieldname, ...
                    '=data(sections(s)+1:sections(s+1)-1);'));
        end
    end
    
    fs = (10^6)/str2double(hdr.commoninfos.SamplingInterval);
    locations = {};
    scale  = [];
    for i = 1:size(hdr.channelinfos,2)
        aux_chan = split(hdr.channelinfos{i}, ',');
        locations{i} = aux_chan{1};
        scale(i) = str2double(aux_chan{3});
    end

    info.eegFile = hdr.commoninfos.DataFile;
    info.DataType = hdr.binaryinfos.BinaryFormat;
    info.scaleFactor  = scale;
end