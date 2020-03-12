%% measure_update_file
% This function is used to update the text file which contains the
% parameters of the study after measure extraction
%
% measure_update_file(cf, measure, totBand, dataPath, fs, epNum, ...
%        epTime, tStart)
%
% input:
%   cf is the array which contains the cut frequencies
%   measure is the name of the extracted measure
%   totBand is the array which contains the cut frequencies of the total
%       frequency band
%   dataPath is the directory of the study
%   fs is the sampling frequency
%   epNum is the number of epochs
%   epTime is the length of the time window of each epoch (in seconds)
%   tStart is the starting time of the first extracted epoch


function measure_update_file(cf, measure, totBand, dataPath, fs, ...
    epNum, epTime, tStart)
    cf_string = '';
    for i = 1:length(cf)
        cf_string = strcat(cf_string, " ", string(cf(i)));
    end
    cf_string = char_check(cf_string);
    cf_string = cf_string(2:end);
    
    if not(strcmp(measure, "PSDr"))
        totBand = [cf(1) cf(end)];
    end
    
    update_file(strcat(path_check(dataPath), path_check(measure), ...
        'auxiliary.txt'), {strcat('dataPath=', char_check(dataPath)), ...
        strcat('fs=', char_check(fs)), ...
        strcat('cf=', char_check(cf_string)), ...
        strcat('epNum=', char_check(epNum)), ...
        strcat('epTime=', char_check(epTime)), ...
        strcat('tStart=', char_check(tStart)), ...
        strcat('totBand=', char_check(strcat(string(totBand(1)), " ", ...
        string(totBand(2))))), ...
        strcat('measures=', char_check(measure))});
end