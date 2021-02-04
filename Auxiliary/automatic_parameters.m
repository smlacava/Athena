%% automatic_parameters
% This function is used to automatically set the parameters of the measure 
% to extract if a parameter is modified.
%
% [epNum, epTime, totBand] = automatic_parameters(handles, ...
%         modified_param, format, time_series, fsOld)
%
% Input:
%   handles are the GUI handles
%   modified_param is the name of the modified parameter (fs for the
%       sampling frequency, tStart for the starting time, epNum for the
%       number of epochs, epTime for the time of each epoch or cf for the 
%       cut frequencies)
%   format is the format of the data files, or 'False' search if an 
%       unspecified format has to be searched (optional, False by default)
%   time_series is the data matrix (0 by default)
%   fsOld is the current sampling frequency (0 by default)
%
% Output:
%   epNum is the number of epochs
%   epTime is the time of each epoch
%   totBand is a string which represent the cut frequencies of the total
%       frequency band

function [epNum, epTime, totBand] = automatic_parameters(handles, ...
    modified_param, format, time_series, fsOld)
    if nargin == 2
        format = 'False';
    end
    if nargin == 3
        time_series = 0;
    end
    if nargin == 4
        fsOld = 0;
    end
    
    w_ep = 20; % whished minimum epoch length
    dataPath = char_check(get(handles.aux_dataPath, 'String'));
    dataPath = path_check(dataPath);
    
    if time_series == 0 || fsOld == 0 
        if strcmpi(format, 'False')
            cases = define_cases(dataPath);
        else
            cases = define_cases(dataPath, 1, format);
        end
        [time_series, fsOld] = load_data(strcat(dataPath, cases(1).name));
    end
    
    fs = str2double(get(handles.fs_text, 'String'));
    if fsOld ~= fs & fsOld ~= -1
        [p, q] = rat(fs/fsOld);
        time_series = resample(time_series', p, q)';
    end
    totlen = size(time_series, 2)/fs;
    tStart = str2double(get(handles.tStart_text, 'String'));
    totBand = get(handles.totBand_text, 'String');
    epTime = get(handles.epTime_text, 'String');
    epNum = get(handles.epNum_text, 'String');
    
    if sum(strcmp(modified_param, ["fs", "tStart"]))
        if totlen > (w_ep+tStart)
            epTry = [5 4 3 2 1];
            for i = 1:length(epTry)
                ep = epTry(i);
                if (totlen > (w_ep*ep+tStart))
                    epTime = string(floor((totlen-tStart)/ep));
                    epNum = string(ep);
                    break;
                end
            end
        end
    end
    
    if strcmp(modified_param, "epNum")
        epNum = str2double(get(handles.epNum_text, 'String'));
        epTime = string(floor((totlen-tStart)/epNum));
    end
    
    if strcmp(modified_param, "epTime")
        epTime = str2double(get(handles.epTime_text, 'String'));
        epNum = floor((totlen-tStart)/epTime);
        if str2double(get(handles.epNum_text, 'String')) > epNum
            problem("The total time is higher than the time series one")
        end
    end
    
    if strcmp(modified_param, "cf")
        cf = str2double(split(get(handles.cf_text, 'String'), ' '))';
        totBand = strcat(string(cf(1)), " ", string(cf(end)));
        for i = 1:length(cf)
            if cf(i) < 0
                problem("The cf values cannot be less than 0")
                totBand = get(handles.totBand_text, 'String');
                break;
            elseif i < length(cf)
                if cf(i) >= cf(i+1)
                    problem("The cf are not in order")
                    totBand = get(handles.totBand_text, 'String');
                end
            end
        end
    end
end