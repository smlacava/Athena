%% ind_corr_asy
% This function is used by the index_correlation function to compute the
% index correlation on the asymmetry on not-connectivity measures

function [RHO, P, RHOsig, figs]=ind_corr_asy(data, Ind, RightLoc, LeftLoc, cons, measure, sub)

    figs=[];
    Ind=Ind(:,end);
    if length(size(data))==3
        nBands=size(data,2);
        data_asy=zeros(size(data,1),nBands,2);
        data_asy(:,:,1)=mean(data(:,:,RightLoc),3);
        data_asy(:,:,2)=mean(data(:,:,LeftLoc),3);

        P=zeros(nBands,1);
        RHO=P;
        RHOsig=[string() string()];
        alpha=alpha_levelling(cons,nBands);
        
        for i = 1:nBands
            asy=abs(data_asy(:,i,1)-data_asy(:,i,2));
            [RHO(i,1), P(i,1)]=corr(Ind,asy,'type','Spearman');
            if P(i,1)<alpha
                RHOsig=[RHOsig; strcat('Band',string(i)),string(RHO(i,1))];    
                correlation(Ind, asy(:,i), strcat('Asymmetry, Band ',string(i)), "Index", measure, sub);
            end
        end

    else
        data_asy=zeros(size(data,1),2);
        data_asy(:,1)=mean(data(:,RightLoc),2);
        data_asy(:,2)=mean(data(:,LeftLoc),2);

        RHOsig=string();
        alpha=alpha_levelling(cons);
        
        asy=abs(data_asy(:,1)-data_asy(:,2));
        [RHO, P]=corr(Ind,asy,'type','Spearman');
        if P<alpha
        	RHOsig=[RHOsig; string(RHO)];
            correlation(Ind, asy, strcat('Asymmetry'), "Index", measure, sub);         
        end
    end
    RHOsig(1,:)=[];
end