function ep_scatter(data, nEpochs, nBands, name, yname, save_check, format, dataPath)
    if nargin == 3
        name = '';
        yname = '';
    end
    if nargin < 6
        save_check = 0;
        format = '';
        dataPath = '';
    end
    figure('Name', name, 'NumberTitle', 'off', 'ToolBar', 'none')
    set(gcf, 'color', [1 1 1])
    xlabel('Bands')
    ylabel(yname)
    bands = nBands;
    if iscell(nBands) || isstring(nBands)
        nBands = length(nBands);
        xticks(1:nBands)
        xticklabels(bands)
    else
        xticks(1:nBands)
    end
    xlim([0, nBands+1])
    hold on
    labels = [];        
    for i = 1:nBands
        scatter(i*ones(1, nEpochs), data(i, :, :), 'MarkerEdgeColor', ...
            [0.067 0.118 0.424])
        labels = [labels, 1:nEpochs];
    end
    if save_check == 1
        try
            outDir = create_directory(dataPath, 'Figures');
            if strcmp(format, '.fig')
                savefig(char_check(strcat(path_check(outDir), ...
                    'EpochsAnalysis_', strcat(char_check(name), " ", ...
                    char_check(areas(i))), ...
                    measure, format)));
            else
                Image = getframe(gcf);
                imwrite(Image.cdata, char_check(strcat(...
                    path_check(outDir), 'EpochsAnalysis_', ...
                    name, format)));
            end
        catch
        end
    end
    hold off
    gname(labels)
end