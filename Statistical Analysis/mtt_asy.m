%% mtt_asy
% This function is used by the mult_t_test function to compute the
% statistical analysis on the asymmetry on not-connectivity measures

function [P, Psig, data, dataSig]=mtt_asy(PAT, HC, RightLoc, LeftLoc, cons)
    dataSig=[];
    
    if length(size(HC))==3
        nBands=size(HC,2);
        nPAT=size(PAT,1);
        nHC=size(HC,1);
        
        HC_asy=zeros(nHC,nBands,2);
        HC_asy(:,:,1)=mean(HC(:,:,RightLoc),3);
        HC_asy(:,:,2)=mean(HC(:,:,LeftLoc),3);
        
        PAT_asy=zeros(nPAT,nBands,2);
        PAT_asy(:,:,1)=mean(PAT(:,:,RightLoc),3);
        PAT_asy(:,:,2)=mean(PAT(:,:,LeftLoc),3);
        
        data=zeros(nHC+nPAT,nBands);
        Psig=[string(), string()];
        P=zeros(nBands,1);
        alpha=alpha_levelling(cons,nBands);
        
        for i = 1:nBands
            data(1:nHC,i)=abs(HC_asy(:,i,1)-HC_asy(:,i,2));
            data(nHC+1:end,i)=abs(PAT_asy(:,i,1)-PAT_asy(:,i,2));
            P(i,1) = ranksum(data(1:nHC,i),data(nHC+1:end,i));
            
            
            if P(i,1)<alpha
                diff=mean(data(1:nHC,i))-mean(data(nHC+1:end,i));
                dataSig=[dataSig data(:,i)];
                if diff>0
                    Psig=[Psig; strcat("Band ", string(i)), "HC"];
                else
                    Psig=[Psig; string(i), "PAT"];
                end
                
            end
        end
        Psig(1,:)=[];
    else
        nPAT=size(PAT,1);
        nHC=size(HC,1);
    
        HC_asy=zeros(nHC,2);
        HC_asy(:,1)=mean(HC(:,RightLoc),2);
        HC_asy(:,2)=mean(HC(:,LeftLoc),2);
    
        PAT_asy=zeros(nPAT,2);
        PAT_asy(:,1)=mean(PAT(:,RightLoc),2);
        PAT_asy(:,2)=mean(PAT(:,LeftLoc),2);
        
        data=zeros(nHC+nPAT,1);
        data(1:nHC,1)=abs(HC_asy(:,1)-HC_asy(:,2));
        data(nHC+1:end,1)=abs(PAT_asy(:,1)-PAT_asy(:,2));
        
        P = ranksum(data(1:nHC,1),data(nHC+1:end,1));
        Psig="";
        alpha=alpha_levelling(cons,1);
        
        if P<alpha
            diff=mean(data(1:nHC,1))-mean(data(nHC+1:end,1));
            dataSig=[dataSig data(:,1)];
            if diff>0
                Psig="HC";
            else
                Psig="PAT";
            end
        end
    end
end