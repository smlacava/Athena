%% distributions_histogram
% This function shows the histogram of two distributions, in order to
% compare them
%
% distributions_histogram(first_group, second_group, measure, ...
%        labels, location, band, parameter)
%
% input:
%   first_group is the first row or column data vector
%   second_group is the second row or column data vector
%   measure is the name of the measure to plot (optional)
%   labels is the cell array which contains the name of each group
%       (optional, {'first group', 'second group'} by default)
%   location is the name of the compared location (optional)
%   band is the number of the frequency band (optional)
%   bins is the number of bins of the histogram, and can take numeric
%       values (10 as default)


function distributions_histogram(first_group, second_group, measure, ...
    labels, location, band, bins)

    if nargin < 3
        measure = '';
    end
    title = measure;
    if nargin > 4
        title = strcat(title, " ", location);
    end
    if nargin > 5
        title = strcat(title, " Band ", string(band));
    end
    if nargin < 7
        bins = 10;
    end
    
    if size(first_group, 1) < size(first_group, 2)
        first_group = first_group';
        second_group = second_group';
    end
      
    
    figure('Name', title, 'NumberTitle', 'off', 'ToolBar', 'none');
    set(gcf, 'color', [1 1 1])
    if not(isempty(second_group)) && not(isempty(first_group))
        xmax = max(max(max(second_group)), max(max(first_group)))*1.1;
        if length(bins) == 1
            bins = linspace(0, xmax, bins+1);
        end
    	subplot(2, 1, 1)
        histogram(first_group, bins, 'FaceColor', [0.43, 0.8, 0.72], ...
            'FaceAlpha', 1)
        xlabel(measure)
        xlim([0, xmax])
        legend(labels{1})
        L = ylim;
        ylim([L(1) L(2)*1.1])
        subplot(2, 1, 2)
        histogram(second_group, bins, 'FaceColor', [0.07, 0.12, 0.42], ...
            'FaceAlpha', 1)
        xlabel(measure)
        xlim([0, xmax])
        legend(labels{2})
        L = ylim;
        ylim([L(1) L(2)*1.1])
    elseif not(isempty(second_group))
        xmax = max(max(second_group))*1.1;
        if length(bins) == 1
            bins = linspace(0, xmax, bins+1);
        end
        histogram(second_group, bins, 'FaceColor', [0.07, 0.12, 0.42], ...
            'FaceAlpha', 1)
        xlabel(measure)
        legend(labels{2})
        L = ylim;
        ylim([L(1) L(2)*1.1])
    elseif not(isempty(first_group))
        xmax = max(max(first_group))*1.1;
        if length(bins) == 1
            bins = linspace(0, xmax, bins+1);
        end
        histogram(first_group, bins, 'FaceColor', [0.43, 0.8, 0.72], ...
            'FaceAlpha', 1)
        xlabel(measure)
        legend(labels{1})
        L = ylim;
        ylim([L(1) L(2)*1.1])
    else
        problem('Values not found or not valid.')
        return;
    end
end