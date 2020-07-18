%% ep_plot
% This function plots the variation of the value of a measure of a subject
% (or a group of subjects), related to a location, in a frequency band.
%
% ep_plot(data, nEpochs, measure, title, save_check, format, dataPath)
%
% Input:
%   data is the array which contains the values of the value to analyze
%   nEpochs is the number of epochs (optional, if it is not used or it is
%       [], then the related value will be computed as the number of values
%       of the data array)
%   measure is the name of the analyzed measure ('Measure' as default)
%   title is the title of the resulting image ('' by default)
%   save_check is 1 if the resulting figure has to be saved (0 by default)
%   format is the format of the eventually saved resulting figure (.jpg or
%       .mat, .mat by default)
%   dataPath it the main folder of the study


function ep_plot(data, nEpochs, measure, title, save_check, format, ...
    dataPath)

    if nargin < 2 || isempty(nEpochs)
        nEpochs = length(data);
    end
    if nargin < 3
        measure = 'Measure';
    end
    if nargin < 4
        title = '';
    end
    if nargin < 5
        save_check = 0;
    end
    if nargin < 6
        format = '';
    end
    if nargin < 7
        dataPath = '';
    end
    
    figure('Name', title, 'NumberTitle', 'off', 'ToolBar', 'none')
    set(gcf, 'color', [1 1 1])
    xlabel('Epochs')
    xticks(1:nEpochs)
    ylabel(measure)
    hold on       
    plot(1:nEpochs, data, 'b')
    
    if save_check == 1
        try
            outDir = create_directory(dataPath, 'Figures');
            if strcmp(format, '.fig')
                savefig(char_check(strcat(path_check(outDir), ...
                    'EpochsAnalysis_', measure, '_', title, format)));
            else
                Image = getframe(gcf);
                imwrite(Image.cdata, char_check(strcat(...
                    path_check(outDir), 'EpochsAnalysis_', measure, ...
                    '_', title, format)));
            end
        catch
        end
    end
    
    hold off
end