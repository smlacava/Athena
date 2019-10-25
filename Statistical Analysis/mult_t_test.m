%% mult_t_test
% This function computes the Wicox's analysis between patterns of 2
% different groups. If required, it gives in output a matrix which can be
% used for another statistical analysis or a classification with another
% software.
% 
% [P, Psig, locList, data]=mult_t_test(group1, group2, locations, connCheck, studyType, cons)
%
% input:
%   group1 is the name of the file (with its directory) which contains the
%   	matrix subjects*bands*locations of the first group of subjects
%   group2 is the name of the file (with its directory) which contains the
%       matrix subjects*bands*locations of the second group of subjects
%   locFile is the name of the file (with its directry) which contains
%       the matrix of the channels or the ROIs (in the first column)
%   connCheck is a check which indicates if the measure to test is a
%       connectivity measure (connCheck=1) or not (connCheck=0)
%   studyType is the type of the statistical study (total [default], areas,
%        asymmetry or global)
%   cons is the level of conservativeness which determinates the
%       significativity of any difference (0=no conservativeness [default],
%       1=max conservativeness)
%
% output:
%   P is the p-value matrix
%   Psig is the significativity matrix
%   data is the (optional) output matrix subjects*(bands*locations) useful
%       for external analysis (for example, other statistical analysis,
%       correlation analysis or classification)

function [P, Psig, locList, data, dataSig]=mult_t_test(group1, group2, locFile, connCheck, studyType, cons)
    
    switch nargin
        case 4
            studyType='total';
            cons=0;
        case 5
            cons=0;
    end
    PAT=load_data(group1);
    HC=load_data(group2);
    locations=load_data(locFile);
    switch studyType
        case "asymmetry"
            [RightLoc, LeftLoc]=asymmetry_manager(locations);
            locList="Asymmetry";
            if connCheck==0
                [P, Psig, data, dataSig]=mtt_asy(PAT, HC, RightLoc, LeftLoc, cons);
            else
                [P, Psig, data, dataSig]=mtt_asy_conn(PAT, HC, RightLoc, LeftLoc, cons);
            end
        case "areas" 
            [CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc]=areas_manager(locations);
            if connCheck==0
                [P, Psig, data, dataSig, locList]=mtt_areas(PAT, HC, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc, cons);
            else
                [P, Psig, data, dataSig, locList]=mtt_areas_conn(PAT, HC, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc, cons); 
            end
            
        case "total"
            if connCheck==0
                [P, Psig, data, dataSig]=mtt_tot(PAT, HC, locations, cons);
            else
                [P, Psig, data, dataSig]=mtt_tot_conn(PAT, HC, locations, cons); 
            end
            locList=locations(:,1);
        otherwise
            if connCheck==0
                [P, Psig, data, dataSig]=mtt_glob(PAT, HC, cons);
            else 
                [P, Psig, data, dataSig]=mtt_glob_conn(PAT, HC, cons); 
            end
            locList="Global";
    end
    if nargout==4
        data=classification_support(data);
    end
end