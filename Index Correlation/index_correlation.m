%% index correlation
% This function computes the correlation between a measure matrix and an
% index array relative to each analyzed subject.
% 
% [RHO, P, RHOsig, locList] = index_correlation(data, Ind, locations, ...
%     connCheck, studyType, cons, measure)
%
% input:
%   data is the data matrix to manage to correlate
%   Ind is the file (path and name) which contains the index array
%   locFile is the name of the file (with its directry) which contains
%       the matrix of the channels or the ROIs (in the first column)
%   connCheck is a check which indicates if the measure to test is a
%       connectivity measure (connCheck=1) or not (connCheck=0)
%   studyType is the type of the statistical study (total [default], areas,
%        asymmetry or global)
%   cons is the level of conservativeness which determinates the
%       significativity of any difference (0=no conservativeness [default],
%       1=max conservativeness)
%   measure is the name of the analyzed measure
%
% output:
%   RHO is the Spearman's rhos matrix
%   P is the p-values matrix
%   RHOsig is an array which contains the data concerning significant
%       correlations
%   locList is an array which contains the list of analyzed areas
%   sub is the array of the names of the subjects

function [RHO, P, RHOsig, locList] = index_correlation(dataFile, Ind, ...
    locFile, connCheck, studyType, cons, measure, sub)
    switch nargin
        case 4
            studyType = 'total';
            cons = 0;
            measure = '';
            sub = [];
        case 5
            cons = 0;
            measure = '';
            sub = [];
        case 6
            measure = '';
            sub = [];
        case 7
            sub = [];
    end
    
    data = load_data(dataFile);
    load(Ind)
    
    
    locations = load_data(locFile);
    
    switch studyType
        case 'asymmetry'
            [RightLoc, LeftLoc] = asymmetry_manager(locations);
            locList = 'Asymmetry';
            if connCheck == 0
                [RHO, P, RHOsig] = ind_corr_asy(data, Ind, RightLoc, ...
                    LeftLoc, cons, measure, sub);
            else
                [RHO, P, RHOsig] = ind_corr_asy_conn(data, Ind, ...
                    RightLoc, LeftLoc, cons, measure, sub);
            end
        case 'areas' 
            [CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ...
                ParietalLoc] = areas_manager(locations);
            if connCheck == 0
                [RHO, P, RHOsig, locList] = ind_corr_areas(data, Ind, ...
                    FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, ...
                    CentralLoc, cons, measure, sub);
            else
                [RHO, P, RHOsig, locList] = ind_corr_areas_conn(data, ...
                    Ind, FrontalLoc, TemporalLoc, OccipitalLoc, ...
                    ParietalLoc, CentralLoc, cons, measure, sub); 
            end
            
        case 'total'
            if connCheck == 0
                [RHO, P, RHOsig] = ind_corr_tot(data, Ind, locations, ...
                    cons, measure, sub);
            else
                [RHO, P, RHOsig] = ind_corr_tot_conn(data, Ind, ...
                    locations, cons, measure, sub); 
            end
            locList = locations;
        otherwise
            if connCheck == 0
                [RHO, P, RHOsig] = ind_corr_glob(data, Ind, cons, ...
                    measure, sub);
            else 
                [RHO, P, RHOsig] = ind_corr_glob_conn(data, Ind, cons, ...
                    measure, sub); 
            end
            locList = 'Global';
    end
end