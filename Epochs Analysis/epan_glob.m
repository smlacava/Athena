function epan_glob(data, nEpochs, nBands, measure, name)
    dim=size(data);
    if length(dim)==2
        aux=zeros(1,dim(1),dim(2));
        aux(1,:,:)=data;
        data=aux;
    end
    
    glob=mean(data,3);
    
    ep_scatter(glob, nEpochs, nBands, strcat(string_check(name),' Global'), measure)