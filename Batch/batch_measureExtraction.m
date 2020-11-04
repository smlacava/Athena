%% batch_measureExtraction
% This function is used in the batch mode to extract the selected measure.
%
% batch_measureExtraction(parameters, dataPath, measure, cf)
%
% input: 
%   parameters is the cell array which contains the pairs name-value used
%       in the batch study
%   dataPath is the main directory of the study (optional)
%   measure is the string which represents the measure to extract, or a
%       list which contains the list of measures (optional)
%   cf is the array containing the cut frequencies (optional)


function batch_measureExtraction(parameters, dataPath, measure, cf)
    if nargin < 2
        dataPath = path_check(search_parameter(parameters, 'dataPath'));
    end
    if nargin < 3
        measure = search_parameter(parameters, 'measures');
    end
    if nargin < 4
        cf = search_parameter(parameters, 'cf');
    end

    n_measures = length(measure);
    epNum = search_parameter(parameters, 'epNum');
    fs = search_parameter(parameters, 'fs');
    epTime = search_parameter(parameters, 'epTime');
    tStart = search_parameter(parameters, 'tStart');
    filter_file = search_parameter(parameters, 'filter_file');
    if isempty(filter_file)
        filter_name = 'athena_filter';
    else
        filter_name = batch_check_filter(filter_file);
    end
    
    for m = 1:n_measures
        if strcmp(measure{m}, 'PSDr') && ...
                length(search_parameter(parameters, 'totBand')) ~= 2
            problem('Invalid total band')
            return
        end
        [type, ~] = type_check(measure{m});
        if strcmpi(measure{m}, 'PSDr')
            PSDr(fs, cf, epNum, epTime, dataPath, tStart, ...
                search_parameter(parameters, 'totBand'))
            
        elseif strcmpi(measure{m}, 'PEntropy')
            spectral_entropy(fs, cf, epNum, epTime, dataPath, tStart)
            
        elseif strcmpi(measure{m}, 'approximate_entropy') || ...
                strcmpi(measure{m}, 'sample_entropy') || ...
                strcmpi(measure{m}, 'discretized_entropy')
            time_entropy(fs, cf, epNum, epTime, dataPath, tStart, ...
                [measure{m}], filter_name);
            
        elseif strcmpi(measure{m}, 'offset') || ...
                strcmpi(measure{m}, 'exponent')
            cf_bg = [cf(1), cf(end)];
            FOOOFer(fs, cf_bg, epNum, epTime, dataPath, tStart, type)
            
        else
            connectivity(fs, cf, epNum, epTime, dataPath, tStart, ...
                measure{m}, filter_name)         
        end
        
        measure_update_file(cf, measure{m}, ...
            search_parameter(parameters, 'totBand'), dataPath, fs, ...
            epNum, epTime, tStart);
        pause(1)
    end
end