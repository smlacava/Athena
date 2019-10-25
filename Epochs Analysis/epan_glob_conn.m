function epan_glob_conn(data, nEpochs, nBands, measure, name)
    dim=size(data);
    if length(dim)==3
        aux=zeros(1,dim(1),dim(2),dim(3));
        aux(1,:,:)=data;
        data=aux;
    end
    
    glob=squeeze(sum(data,[3 4])/(dim(3)*dim(3)-dim(3)));
    
    
    ep_scatter(glob, nEpochs, nBands, strcat(string_check(name),' Global'), measure)