%% meas_man_glob-conn
% This function is used by the measures_manager function to manage the data
% matrices of the global connectivity measures

function [data]=meas_man_glob_conn(data_pre)

    nLoc=size(data_pre,3);
    nSub=size(data_pre,1);

    if length(size(data_pre))==4    
        nBands=size(data_pre,2);
        data=zeros(nSub,nBands,1);
        data(:,:,1)=squeeze(sum(data_pre,[3 4])/(nLoc*nLoc-nLoc));
    else
        data=zeros(nSub,1,1);
        data(:,1,1)=sum(data_pre,[2 3])/(nLoc*nLoc-nLoc);
    end
end

