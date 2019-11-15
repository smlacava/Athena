%% automatic_parameters
% This function is used to automatically set the parameters of the measure 
% to extract if a parameter is modified.
%
% [epNum, epTime, totBand] = automatic_parameters(handles, modified_param)
%
% input:
%   handles are the GUI handles
%   modified_param is the name of the modified parameter (fs for the
%       sampling frequency, tStart for the starting time, epNum for the
%       number of epochs, epTime for the time of each epoch or cf for the 
%       cut frequencies)
% output:
%   epNum is the number of epochs
%   epTime is the time of each epoch
%   totBand is a string which represent the cut frequencies of the total
%       frequency band

function [epNum, epTime, totBand] = automatic_parameters(handles, ...
    modified_param)
    dataPath = char_check(get(handles.aux_dataPath, 'String'));
    dataPath = path_check(dataPath);
    cases = define_cases(dataPath);
    time_series = load_data(strcat(dataPath, cases(1).name));
    fs = str2double(get(handles.fs_text, 'String'));
    totlen = size(time_series, 2)/fs;
    tStart = str2double(get(handles.tStart_text, 'String'));
    totBand = get(handles.totBand_text, 'String');
    epTime = get(handles.epTime_text, 'String');
    epNum = get(handles.epNum_text, 'String');
    
    if sum(strcmp(modified_param, ["fs", "tStart"]))
        if totlen > (12+tStart)
            epTry = [5 4 3 2 1];
            for i = 1:length(epTry)
                ep = epTry(i);
                if (totlen > (12*ep+tStart))
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
        if str2double(get(handles.epNum_text, 'String')) < epNum
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