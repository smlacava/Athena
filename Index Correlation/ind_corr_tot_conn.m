%% ind_corr_tot_conn
% This function is used by the index_correlation function to compute the
% index correlation in the single locations on connectivity measures

function [RHO, P, RHOsig]=ind_corr_tot_conn(data, Ind, locations, cons, measure, sub)

    nLoc=length(locations);
    Ind=Ind(:,end);
    
    if length(size(data))==4    
        nBands=size(data,2);
        
        P=zeros(nBands,nLoc);
        RHO=P;
        RHOsig=[string() string() string()];
        alpha=alpha_levelling(cons,nLoc,nBands);
        
        for i = 1:nBands
            for j = 1:nLoc
                tot=sum(data(:,i,j,:),4)/(nLoc-1);
                [RHO(i,j), P(i,j)]=corr(Ind,tot,'type','Spearman');
                if P(i,j)<alpha
                    RHOsig=[RHOsig; strcat("Band",string(i)), locations(j), string(RHO(i,j))];
                    correlation(Ind, tot, strcat('Band ',string(i),', ',locations(j)), "Index", measure, sub);
                end
            end
        end            
    else
        RHOsig=string();
        P=zeros(1,nLoc);
        RHO=P;
        alpha=alpha_levelling(cons,nLoc);
        
        for i = 1:nLoc
            tot=sum(data(:,i,:),3)/(nLoc-1);
            [RHO(1,i), P(1,i)]=corr(Ind,tot,'type','Spearman');
            if P(1,i)<alpha
                RHOsig=[RHOsig; locations(i)];
                correlation(Ind, tot, strcat(locations(i)), "Index", measure, sub);
            end
        end
    end
    RHOsig(1,:)=[];
end

