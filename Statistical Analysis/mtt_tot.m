%% mtt_tot
% This function is used by the mult_t_test function to compute the
% statistical analysis in the single locations on not-connectivity measures

function [P, Psig, data, dataSig]=mtt_tot(PAT, HC, locations, cons)
    nLoc=length(locations);
    dataSig=[];
    
    if length(size(HC))==3
        nBands=size(HC,2);
        nPAT=size(PAT,1);
        nHC=size(HC,1);
        
        data=zeros(nHC+nPAT,nBands,nLoc);
        Psig=[string(), string() string()];
        P=zeros(nBands,nLoc);
        
        alpha=alpha_levelling(cons,nLoc,nBands);
        
        for i = 1:nBands
            for j = 1:nLoc
                data(1:nHC,i,j)=HC(:,i,j);
                data(nHC+1:end,i,j)=PAT(:,i,j);
                P(i,j) = ranksum(data(1:nHC,i,j),data(nHC+1:end,i,j));
                if P(i,j)<alpha
                    diff=mean(data(1:nHC,i,j))-mean(data(nHC+1:end,i,j));
                    dataSig=[dataSig data(:,i,j)];
                    if diff>0
                        Psig=[Psig; strcat("Band",string(i)), locations(j),"major in HC"];
                    else
                        Psig=[Psig; strcat("Band",string(i)), locations(j), "major in PAT"];
                    end
                end
                
            end
        end

    else
        nPAT=size(PAT,1);
        nHC=size(HC,1);
        
        data=zeros(nHC+nPAT,nLoc);
        Psig=[string() string()];
        P=zeros(1,nLoc);
        
        alpha=alpha_levelling(cons,nLoc);
        
        for i = 1:nLoc
        	data(1:nHC,i)=HC(:,i);
            data(nHC+1:end,i)=PAT(:,i);
            P(1,i) = ranksum(data(1:nHC,i),data(nHC+1:end,i));
            
            if P(1,i)<alpha
                diff=mean(data(1:nHC,i))-mean(data(nHC+1:end,i));
                dataSig=[dataSig data(:,i)];
                if diff>0
                    Psig=[Psig; locations(i), "major in HC"];
                else
                    Psig=[Psig; locations(i), "major in PAT"];
                end
                
            end
        end
    end
    Psig(1,:)=[];
end