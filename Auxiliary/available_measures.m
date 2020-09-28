%% available_measures
% This function returns the list of the computed measures, as well as the
% list of network metrics computed on the connectivity measures, in form 
% "measure-network metric" (for example, "PLI-Betweenness Centrality").
%
% measures = available_measures(dataPath, networkFLAG, aperiodicFLAG)
%
% Input:
%   dataPath is the main directory of the study
%   networkFLAG has to be 1 in order to include the computed network
%       metrics in the list (0 by default)
%   aperiodicFLAG has to be 1 in order to include the aperiodic measures
%       (offset and exponent) in the list (0 by default)
%
% Output:
%   measures is the string array which elements are the computed measures
%       and the computed network metrics


function measures = available_measures(dataPath, networkFLAG, ...
    aperiodicFLAG)
    if nargin < 2
        networkFLAG = 0;
    end
    if nargin < 3
        aperiodicFLAG = 0;
    end
    
    cases = dir(dataPath);
    measures = [];
    for i = 1:length(cases)
      	if cases(i).isdir == 1
            if sum(strcmp(cases(i).name, Athena_measures_list(1, ...
                    aperiodicFLAG)))
                measures = [measures, string(cases(i).name)];
            end
        end
    end
    
    if networkFLAG == 1
        network_measures = network_computed(dataPath, measures);
        for i = 1:length(network_measures)
            measures = [measures, char(network_measures(i))];
        end
    end
end