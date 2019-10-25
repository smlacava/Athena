function epan_tot(data, nEpochs, nBands, measure, name, locations)
    
    nLoc=length(locations);

    dim=size(data);
    if length(dim)==2
        aux=zeros(1,dim(1),dim(2));
        aux(1,:,:)=data;
        data=aux;
    end
    for i=1:nLoc
        ep_scatter(data(:,:,i), nEpochs, nBands, strcat(string_check(name),' ',string_check(locations(i,1))), measure)
    end