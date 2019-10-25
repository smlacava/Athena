%% meas_man_asy
% This function is used by the measures_manager function to manage the data
% matrices of the not-connectivity measures on the asymmetry

function [data]=meas_man_asy(data_pre, RightLoc, LeftLoc)
    nSub=size(data_pre,1);

    if length(size(data_pre))==3
        nBands=size(data_pre,2);
        data_asy=zeros(nSub,nBands,2);
        data_asy(:,:,1)=mean(data_pre(:,:,RightLoc),3);
        data_asy(:,:,2)=mean(data_pre(:,:,LeftLoc),3);

        data=zeros(nSub,nBands);
        for i = 1:nBands
            data(:,i)=abs(data_asy(:,i,1)-data_asy(:,i,2));
        end

    else
        data_asy=zeros(nSub,2);
        data_asy(:,1)=mean(data_pre(:,RightLoc),2);
        data_asy(:,2)=mean(data_pre(:,LeftLoc),2);
        
        data=zeros(nSub,1,1);
        data(:,1,1)=abs(data_asy(:,1)-data_asy(:,2));
    end
end