%% meas_man_glob
% This function is used by the measures_manager function to manage the data
% matrices of the global not-connectivity measures

function [data]=meas_man_glob(data_pre)
    nSub=size(data_pre,1);

    if length(size(data_pre))==3
        nBands=size(data_pre,2);
        data=zeros(nSub,nBands,1);
        for i = 1:nBands
            data(:,i,1)=squeeze(mean(data_pre(:,i,:),3));
        end

    else
        data=zeros(nSub,1,1);
        data(:,1,1)=squeeze(mean(data_pre,2));
    end
end