%% batch_measureExtraction
% This function is used in the batch mode to extract the selected measure.
%
% batch_measureExtraction(measure, fs, cf, epNum, epTime, dataPath, ...
%   tStart, totBand)
%
% input: 
%   measure is the string which represents the measure to extract
%   fs is the sampling frequency
%   cf is the array containing the cut frequencies
%   epNum is the number of epochs
%   epTime is the time window of each epoch
%   dataPath is the name of the directory (with its path) which contains
%       the time series
%   tStart is the initial time of the first epoch
%   totBand is an array containing the minimum and the maximum cut
%       frequency to use in the extraction (used to extract the 
%       relative PSD)


function batch_measureExtraction(measure, fs, cf, epNum, epTime, ...
    dataPath, tStart, totBand)
    
    cases = define_cases(dataPath);
    time_series = load(strcat(dataPath, cases(1).name));
    if length(time_series) < (tStart+(epNum*epTime))
        problem("The time series has not enough samples")
        return
    end
    
    if strcmp(measure, "PSDr")
        PSDr(fs, cf, epNum, epTime, dataPath, tStart, totBand)
    elseif strcmp(measure, "PEntropy")
        PSDr(fs, cf, epNum, epTime, dataPath, tStart)
    elseif sum(strcmp(measure, ["exponent", "offset"]))
        FOOOFer(fs, cf, epNum, epTime, dataPath, tStart, measure)
    else
        connectivity(fs, cf, epNum, epTime, dataPath, tStart, measure)
    end
        
    auxID=fopen('auxiliary.txt', 'w');
    fprintf(auxID, 'dataPath=%s', dataPath);
    fprintf(auxID, '\nfs=%d', fs);
    fprintf(auxID, '\ncf=');
    for i = 1:length(cf)
        fprintf(auxID, '%d ', cf(i));
    end
    fprintf(auxID, '\nepNum=%d', epNum);
    fprintf(auxID, '\nepTime=%d', epTime);
    fprintf(auxID, '\ntStart=%d', tStart);
    fprintf(auxID, '\ntotBand=%d %d', totBand(1), totBand(2));
    fprintf(auxID, '\nmeasure=%s', measure);
    fclose(auxID);
end