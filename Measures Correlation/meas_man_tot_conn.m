%% meas_man_tot_conn
% This function is used by the measures_manager function to manage the data
% matrices of the connectivity measures in the single locations

function [data]=meas_man_tot_conn(data_pre, locations)

    nLoc=length(locations);
    nSub=size(data_pre,1);

    if length(size(data_pre))==4    
        nBands=size(data_pre,2);
        data=zeros(size(data_pre,1),nBands,nLoc);
        for i = 1:nBands
            for j = 1:nLoc
                data(:,i,j)=sum(data_pre(:,i,j,:),4)/(nLoc-1);
            end
        end    
    else
        data=zeros(nSub,1,nLoc);
        for i = 1:nLoc
            data(:,1,i)=sum(data_pre(:,i,:),3)/(nLoc-1);
        end
    end
end

