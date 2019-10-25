function epan_tot_conn(data, nEpochs, nBands, measure, name, locations)
    
    nLoc=length(locations);

    dim=size(data);
    if length(dim)==3
        aux=zeros(1,dim(1),dim(2),dim(3));
        aux(1,:,:,:)=data;
        data=aux;
    end
    data_tot=sum(data,4)/(nLoc-1);
    for i=1:nLoc
        ep_scatter(data_tot(:,:,i), nEpochs, nBands, strcat(string_check(name),' ',string_check(locations(i,1))), measure)
    end