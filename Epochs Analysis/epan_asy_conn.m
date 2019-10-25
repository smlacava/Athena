function epan_asy_conn(data, nEpochs, nBands, measure, name, RightLoc, LeftLoc)
    R=length(RightLoc);
    R=R*R-R;
    L=length(LeftLoc);
    L=L*L-L;
    
    dim=size(data);
    if length(dim)==3
        aux=zeros(1,dim(1),dim(2),dim(3));
        aux(1,:,:,:)=data;
        data=aux;
    end
    
    data_asy=zeros(nBands, nEpochs, 2);
    data_asy(:,:,1)=sum(squeeze(sum(data(:,:,RightLoc,RightLoc),3)),3)/R;
    data_asy(:,:,2)=sum(squeeze(sum(data(:,:,LeftLoc,LeftLoc),3)),3)/L;
    asy=abs(data_asy(:,:,1)-data_asy(:,:,2));
    
    ep_scatter(asy, nEpochs, nBands, strcat(string_check(name),' Asymmetry'), measure)