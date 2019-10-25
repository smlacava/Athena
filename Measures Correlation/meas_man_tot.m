%% meas_man_tot
% This function is used by the measures_manager function to manage the data
% matrices of the not-connectivity measures in the single locations

function [data]=meas_man_tot(data_pre, locations)

    nLoc=length(locations);
    nSub=size(data_pre,1);

    if length(size(data_pre))==3     
        data=data_pre;      
    else
        data=zeros(nSub,1,nLoc);
        data(:,1,:)=data_pre;
    end
end

