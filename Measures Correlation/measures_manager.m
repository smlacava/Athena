%% measures_manager
% This function manages the data matrix to compute the following
% correlation between two measures.
% 
% [data, locList] = measures_manager(data_pre, locations, connCheck, ...
%     studyType)
%
% input:
%   data_pre is the data matrix to manage
%   locFile is the name of the file (with its directry) which contains
%       the matrix of the channels or the ROIs (in the first column)
%   connCheck is a check which indicates if the measure to test is a
%       connectivity measure (connCheck=1) or not (connCheck=0)
%   studyType is the type of the statistical study (total [default], areas,
%        asymmetry or global)
%
% output:
%   data is the managed data matrix
%   locList is the list of analyzed areas

function [data, locList]=measures_manager(data_pre, locFile, connCheck, studyType)
    
    data_pre=load_data(data_pre);    
    locations=load_data(locFile);
    
    switch studyType
        case 'asymmetry'
            [RightLoc, LeftLoc]=asymmetry_manager(locations);
            locList="Asymmetry";
            if connCheck==0
                data=meas_man_asy(data_pre, RightLoc, LeftLoc);
            else
                data=meas_man_asy_conn(data_pre, RightLoc, LeftLoc);
            end
            
        case 'areas' 
            [CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc]=areas_manager(locations);
            locList=[];
            if length(FrontalLoc)>0
                locList=[locList, "Frontal Area"];
            end
            if length(TemporalLoc)>0
                locList=[locList, "Temporal Area"];
            end
            if length(OccipitalLoc)>0
                locList=[locList, "Occipital Area"];
            end
            if length(ParietalLoc)>0
                locList=[locList, "Parietal Area"];
            end
            if length(CentralLoc)>0
                locList=[locList, "Central Area"];
            end
            
            if connCheck==0
                [data]=meas_man_areas(data_pre, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc);
            else
                [data]=meas_man_areas_conn(data_pre, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc); 
            end
            
        case 'total'
            if connCheck==0
                data=meas_man_tot(data_pre, locations);
            else
                data=meas_man_tot_conn(data_pre, locations); 
            end
            locList="Total";
            
        otherwise
            if connCheck==0
                data=meas_man_glob(data_pre);
            else 
                data=meas_man_glob_conn(data_pre); 
            end
            locList="Global";
    end
end