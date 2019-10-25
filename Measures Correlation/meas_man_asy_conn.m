%% meas_man_asy_conn
% This function is used by the measures_manager function to manage the data
% matrices of the connectivity measures on the asymmetry

function [data]=meas_man_asy_conn(data_pre, RightLoc, LeftLoc)
    nSub=size(data_pre,1);
    R=length(RightLoc);
    R=R*R-R;
    L=length(LeftLoc);
    L=L*L-L;

    if length(size(data_pre))==4
        nBands=size(data_pre,2);
        data_asy=zeros(nSub,nBands,2);
        data_asy(:,:,1)=sum(squeeze(sum(data_pre(:,:,RightLoc,RightLoc),3)),3)/R;
        data_asy(:,:,2)=sum(squeeze(sum(data_pre(:,:,LeftLoc,LeftLoc),3)),3)/L;

        data=zeros(nSub,nBands,1);
        for i = 1:nBands
            data(:,i,1)=abs(data_asy(:,i,1)-data_asy(:,i,2));
        end

    else
        data_asy=zeros(nSub,2);
        data_asy(:,1)=sum(squeeze(sum(data_pre(:,RightLoc,RightLoc),2)),2)/R;
        data_asy(:,2)=sum(squeeze(sum(data_pre(:,LeftLoc,LeftLoc),2)),2)/L;
        data=zeros(nSub,1,1);
        data(:,1,1)=abs(data_asy(:,1)-data_asy(:,2));
    end
end