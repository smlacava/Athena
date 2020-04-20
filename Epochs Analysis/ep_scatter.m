function ep_scatter(data, nEpochs, nBands, name, yname)
    if nargin == 3
        name = '';
        yname = '';
    end
    figure('Name', name, 'NumberTitle', 'off', 'ToolBar', 'none')
    set(gcf, 'color', [1 1 1])
    xlabel('Bands')
    ylabel(yname)
    xticks(1:nBands)
    xlim([0, nBands+1])
    hold on
    labels = [];
    for i = 1:nBands
        scatter(i*ones(1, nEpochs), data(i, :, :), 'MarkerEdgeColor', ...
            [0.067 0.118 0.424])
        labels = [labels, 1:nEpochs];
    end
    hold off
    gname(labels)
end