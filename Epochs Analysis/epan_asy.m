function epan_asy(data, nEpochs, nBands, measure, name, RightLoc, LeftLoc)
    
    dim=size(data);
    if length(dim)==2
        aux=zeros(1,dim(1),dim(2));
        aux(1,:,:)=data;
        data=aux;
    end
    
    data_asy=zeros(nBands, nEpochs, 2);
    data_asy(:,:,1)=mean(data(:,:,RightLoc),3);
    data_asy(:,:,2)=mean(data(:,:,LeftLoc),3);
    asy=abs(data_asy(:,:,1)-data_asy(:,:,2));
    
    ep_scatter(asy, nEpochs, nBands, strcat(string_check(name),' Asymmetry'), measure)
    
        
