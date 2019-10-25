%% meas_man_areas
% This function is used by the measures_manager function to manage the data
% matrices of the not-connectivity measures in the areas

function [data,areas]=meas_man_areas(data_pre, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc)
    Front=length(FrontalLoc);
    Temp=length(TemporalLoc);
    Occ=length(OccipitalLoc);
    Par=length(ParietalLoc);
    Cent=length(CentralLoc);
    areas=string();
    nLoc=0;
    nSub=size(data_pre,1);
    
    if Front~=0
        nLoc=nLoc+1;
        areas=[areas, "Frontal"];
    end
    if Temp~=0
        nLoc=nLoc+1;
        areas=[areas, "Temporal"];
    end
    if Occ~=0
        nLoc=nLoc+1;
        areas=[areas, "Occipital"];
    end
    if Par~=0
        nLoc=nLoc+1;
        areas=[areas, "Parietal"];
    end
    if Cent~=0
        nLoc=nLoc+1;
        areas=[areas, "Central"];
    end
    areas(1)=[];
    
    if length(size(data_pre))==3
        nBands=size(data_pre,2);
        data=zeros(nSub,nBands,nLoc);
        
        loc=1;
        if Front~=0
            data(:,:,loc)=mean(data_pre(:,:,FrontalLoc),3);
            loc=loc+1;
        end
        if Temp~=0
            data(:,:,loc)=mean(data_pre(:,:,TemporalLoc),3);
            loc=loc+1;
        end
        if Occ~=0
            data(:,:,loc)=mean(data_pre(:,:,OccipitalLoc),3);
            loc=loc+1;
        end
        if Par~=0
            data(:,:,loc)=mean(data_pre(:,:,ParietalLoc),3);
            loc=loc+1;
        end
        if Cent~=0
            data(:,:,loc)=mean(data_pre(:,:,CentralLoc),3);
            loc=loc+1;
        end
        loc=loc-1;
        

    else  
        data=zeros(nSub,1,nLoc);
        loc=1;
        if Front~=0
            data(:,1,loc)=mean(data_pre(:,FrontalLoc),2);
            loc=loc+1;
        end
        if Temp~=0
            data(:,1,loc)=mean(data_pre(:,TemporalLoc),2);
            loc=loc+1;
        end
        if Occ~=0
            data(:,1,loc)=mean(data_pre(:,OccipitalLoc),2);
            loc=loc+1;
        end
        if Par~=0
            data(:,1,loc)=mean(data_pre(:,ParietalLoc),2);
            loc=loc+1;
        end
        if Cent~=0
            data(:,1,loc)=mean(data_pre(:,CentralLoc),2);
            loc=loc+1;
        end
        loc=loc-1;
        
    end
end