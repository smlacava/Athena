function ep_scatter(data, nEpochs, nBands, name, yname)
    if nargin==3
        name='';
        yname='';
    end
    figure('Name',name,'NumberTitle','off','ToolBar','none')
    set(gcf, 'color', [0.67 0.98 0.92])
    xlabel('Bands')
    ylabel(yname)
    xticks([1:nBands])
    xlim([0, nBands+1])
    ep=[1:nEpochs];
    hold on
    labels=[];
    for i=1:nBands
        scatter(i*ones(1,nEpochs), data(i,:,:), 'MarkerEdgeColor',[0.05 0.02 0.8])
        labels=[labels, 1:nEpochs];
    end
    gname(labels)
    hold off