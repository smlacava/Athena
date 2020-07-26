%% Athena_measures_list
% This function is used by the toolbox in order to obtain the list of
% allowed measures.
%
% measures = Athena_measures_list(cellFLAG, aperiodicFLAG, ...
%         connectivityFLAG, powerFLAG)
%
% Input:
%   cellFLAG has to be 1 in order to obtain the list as a cell array, or 0
%       to obtain a string array (0 by default)
%   aperiodicFLAG has to be 1 in order to insert the aperiodic measures in
%       the list, or 0 to avoid them (1 by default)
%   connectivityFLAG has to be 1 in order to insert the connectivity
%       measures in the list, or 0 to avoid them (1 by default)
%   powerFLAG has to be 1 in order to insert the power measures in the
%       list, or 0 to avoid them (1 by default)
%       
% 
% Output:
%   measures is the list of allowed measures (in order power measures,
%       connectivity measures and aperiodic measures, if all the FLAGs are 
%       set to 1)


function measures = Athena_measures_list(cellFLAG, aperiodicFLAG, ...
    connectivityFLAG, powerFLAG)
    if nargin < 1
        cellFLAG = 0;
    end
    if nargin < 2
        aperiodicFLAG = 1;
    end
    if nargin < 3
        connectivityFLAG = 1;
    end
    if nargin < 4
        powerFLAG = 1;
    end
    
    connectivity_measures = {'PLI', 'PLV', 'AEC', 'AECo', 'Coherence', ...
        'ICOH'};
    power_measures = {'PSDr'};
    aperiodic_measures = {'Offset', 'Exponent'};
    
    measures = {};
    if powerFLAG == 1
        measures = [measures, power_measures];
    end
    if connectivityFLAG == 1
        measures = [measures, connectivity_measures];
    end
    if aperiodicFLAG == 1
        measures = [measures, aperiodic_measures];
    end
    
    if cellFLAG == 0
        measures = string(measures);
    end
end