%% distributions_scatterplot
% This function shows the distributions, comparing their median or their
% mean
%
% distributions_scatterplot(first_group, second_group, measure, ...
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
%   parameter can take 'mean' to compute the mean of the distribution, or
%       'median' to compute the median of the distribution ('median' by
%       default)


function distributions_scatterplot(first_group, second_group, measure, ...
    labels, location, band, parameter)

    title = '';
    if nargin < 3
        measure = '';
        title = measure;
    end
    if nargin > 4
        title = strcat(measure, " ", location);
    end
    if nargin > 5
        title = strcat(measure, " Band ", string(band));
    end
    if nargin < 6
        title = strcat(measure, " ", location);
    end
    if nargin < 7
        parameter = 'median';
    end
    
    if size(first_group, 1) < size(first_group, 2)
        first_group = first_group';
        second_group = second_group';
    end
    if strcmpi(parameter, 'mean')
        m1 = mean(first_group);
        m2 = mean(second_group);
    else
        m1 = median(first_group);
        m2 = median(second_group);
    end
      
    if isempty(labels)
        labels = {'first group', 'second group'};
    end
    
    figure('Name', title, 'NumberTitle', 'off', 'ToolBar', 'none');
    set(gcf, 'color', [0.67 0.98 0.92])
    scatter(linspace(0.4, 0.6, length(first_group)), first_group, 'b')
    hold on
    plot([0.3, 0.7], [m1, m1], 'k')
    scatter(linspace(1.4, 1.6, length(second_group)), second_group, 'r')
    plot([1.3, 1.7], [m2, m2], 'k')
    xlim([0, 2])
    xticks([0.5, 1.5])
    xticklabels(labels)
    ylabel(measure)
end