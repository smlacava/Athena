%% ind_corr_tot
% This function is used by the index_correlation function to compute the
% index correlation in the single locations on not-connectivity measures

function [RHO, P, RHOsig]=ind_corr_tot(data, Ind, locations, cons, measure, sub)

    nLoc=length(locations);
    Ind=Ind(:,end);
    
    if length(size(data))==3     
        nBands=size(data,2);
        
        P=zeros(nBands,nLoc);
        RHO=P;
        RHOsig=[string() string() string()];
        alpha=alpha_levelling(cons,nLoc,nBands);
        
        for i = 1:nBands
            for j=1:nLoc
                [RHO(i,j), P(i,j)]=corr(Ind,data(:,i,j),'type','Spearman');
                if P(i,j)<alpha
                    RHOsig=[RHOsig; string(i),locations(j), string(RHO(i,j))];
                    correlation(Ind, data(:,i,j), strcat(locations(j), ', Band ',string(i)), "Index", measure, sub);
                end
            end
        end            
    else
        RHOsig=[string() string()];
        RHO=zeros(1,nLoc);
        P=RHO;
        alpha=alpha_levelling(cons,nLoc);

        for i=1:nLoc
            [RHO(1,i), P(1,i)]=corr(Ind,data(:,i),'type','Spearman');
            if P(1,i)<alpha
                RHOsig=[RHOsig; locations(i) string(RHO(1,i))];
                correlation(Ind, data(:,i), strcat(locations(i)), "Index", measure, sub);
            end
        end
    end
    RHOsig(1,:)=[];
end

