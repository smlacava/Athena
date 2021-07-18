%% athena_topoplot_hemiareas
% This function shows a topographic map of a scalp data field by 
% interpolating on a cartesian grid, and/or the channel locations 
% identifying the single areas (frontal, temporal, occipital, parietal and
% central) in the single hemisphere (right and left), eventually 
% highlighting some of them (up to two highlighting colors).
%
% athena_topoplot_hemiareas(values, hemiareas_list, highlighted, ...
%       second_highlighted, channels_plot, contour_plot, clickable)
%
% Input:
%   values is the array of channels values, containing the value related
%       to each channel which has to be used for the interpolation
%   hemiareas_list is the list containing the analyzed areas, among 
%       RightFrontal, LeftFrontal, RightTemporal, LeftTemporal, 
%       RightParietal, LeftParietal, RIghtCentral, LeftCentral, 
%       RightOccipital and LeftOccipital.
%   highlighted is the cell array containing the list of names of the 
%       channels which have to be highlighted (optional, empty by default)
%   second_highlighted is the cell array containing the list of names of 
%       the channels which have to be highlighted with a second color
%       (optional, empty by default)
%   channels_plot has to be 1 to plot the points identtifying the channels,
%       0 otherwise (optional, 1 by default)
%   contour_plot has to be 1 to plot the interpolation of the values, 0 
%       otherwise (optional, 1 by default, in the first case, the primary 
%       highlighting color is white and the second one is purple, while in 
%       the latter case the colors will be red and blue, respectively)
%   clickable has to be 1 to show the names of the channels when the user
%       clicks on them, 0 otherwise (1 by default)


function athena_topoplot_hemiareas(values, hemiareas_list, highlighted, ...
    second_highlighted, channels_plot, contour_plot, clickable)
    
    if nargin < 3
        highlighted = [];
    end
    if nargin < 4
        second_highlighted = [];
    end
    if nargin < 5
        channels_plot = 1;
    end
    if nargin < 6
        contour_plot = 1;
    end
    if nargin < 7 
        clickable = 1;
    end
    
    chanlocs = struct();
    count = 1;
    if size(values, 1) > size(values, 2)
        values = values';
    end
    hemiareas = ["RightFrontal", "LeftFrontal", "RightTemporal", ...
        "LeftTemporal", "RightOccipital", "LeftOccipital", ...
        "RightParietal", "LeftParietal", "RightCentral", "LeftCentral"];
    X = [66, 66, 0, 0, -81, -81, -57.55, -57.55, 0, 0];
    Y = [-34, 34, -84.5, 84.5, -26.13, 26.13, -48, 48, -50, 50];
    Z = [30, 30, -8.84, -8.84, -4, -4, 59.5, 59.5, 40, 40, 68, 68];
    for i = 1:length(hemiareas)
        if sum(contains(hemiareas_list, hemiareas(i))) == 1
            chanlocs(count).labels = char(hemiareas(i));
            chanlocs(count).X = X(i);
            chanlocs(count).Y = Y(i);
            chanlocs(count).Z = Z(i);
            count = count+1;
        end
    end
    if size(highlighted, 1) < size(highlighted, 2)
        highlighted = highlighted';
    end
    if size(second_highlighted, 1) < size(second_highlighted, 2)
        second_highlighted = second_highlighted';
    end
    hl = {};
    hl2 = {};
    if not(isempty(highlighted)) & not(iscell(highlighted))
        for i = 1:size(highlighted, 1)
            hl = [hl, char(highlighted(i))];
        end
        highlighted = hl;
    end
    if not(isempty(second_highlighted)) & not(iscell(second_highlighted))
        for i = 1:size(second_highlighted, 1)
            hl2 = [hl2, char(second_highlighted(i))];
        end
        second_highlighted = hl2;
    end
    athena_topoplot(values, chanlocs, highlighted, ...
        second_highlighted, channels_plot, contour_plot, clickable);
end