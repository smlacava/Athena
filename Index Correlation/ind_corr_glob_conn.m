%% ind_corr_glob_conn
% This function is used by the index_correlation function to compute the
% global index correlation on connectivity measures

function [RHO, P, RHOsig]=ind_corr_glob_conn(data, Ind, cons, measure, sub)

    nLoc=size(data,3);
    Ind=Ind(:,end);
    
    if length(size(data))==4    
        nBands=size(data,2);
        data_glob=squeeze(sum(data,[3 4])/(nLoc*nLoc-nLoc));
        P=zeros(nBands,1);
        RHO=P;
        RHOsig=[string() string()];
        alpha=alpha_levelling(cons,nBands);
        
        for i = 1:nBands
        	[RHO(i,1), P(i,1)]=corr(Ind,data_glob(:,i),'type','Spearman');
            if P(i,1)<alpha
                RHOsig=[RHOsig; strcat('Band',string(i)), string(RHO(i,1))];
                correlation(Ind, data_glob(:,i), strcat('Global, Band ',string(i)), "Index", measure, sub);
            end
        end            
        RHOsig(1,:)=[];
    else
        data_glob=sum(data,[2 3])/(nLoc*nLoc-nLoc);
        RHOsig=[];
        
        alpha=alpha_levelling(cons);
        
        [RHO, P]=corr(Ind,data_glob,'type','Spearman');

        if P<alpha
        	RHOsig=string(RHO);
            correlation(Ind, data_glob, "Global", "Index", measure, sub);
        end
    end
end

