%% show_locations
% This function shows the locations of the channels, making it possible to
% check their names by clicking on the points representing them, and
% eventually to highlight some of them.
%
% f = show_locations(data, locations_list, enabled)
%
% Input:
%   data is the data structure containing the locations information in the
%       chanlocs field (names and coordinates in X, Y, Z)
%   locations_list is the cell array which contains the list of considered 
%       locations (optional, no highlighted channels if it is not given)
%   enables is an array in which each element is 0 or 1 if the related
%       channel in the locations_list array has to be highlighted or not,
%       respectively (optional, no highlighted channels if it is not given)
%
% Output:
%   f is the handle to the figure

function f = show_locations(data, locations_list, enabled)
    if nargin == 1
        enabled = [];
        locations_list = [];
    end
    if not(isfield(data, 'chanlocs'))
        return;
    end
    filename = strcat(path_check(limit_path(mfilename('fullpath'), ...
        'Graphics')), 'docs', filesep, 'head.png');
    head = imread(filename);
    f = figure('Visible', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'name', 'Channel locations', 'NumberTitle','off');
    axis([-110.4, 110.4, -112,  100]);
    set(gca,'XColor', 'none','YColor','none')
    im = image([-110.4, 110.4], [-112,  100], head);
    hold on
    locations = data.chanlocs;
    X = [];
    Y = [];
    names = {};
    for i = 1:length(locations)
        if not(isempty(data.chanlocs(i).X)) && ...
                not(isempty(data.chanlocs(i).Y)) &&  ...
                not(isnan(data.chanlocs(i).X)) && ...
                not(isnan(data.chanlocs(i).Y))
            X = [X, data.chanlocs(i).X];
            Y = [Y, data.chanlocs(i).Y];
            names = [names, locations(i).labels];
        end
    end
    N = length(X);
    X = -X;
    Y = -Y;
        
    if not(isempty(enabled)) && not(isempty(locations_list))
        aux_X = [];
        aux_Y = [];
        for i = 1:N
            idx = find(strcmpi(names{i}, locations_list));
            if not(isempty(idx)) && enabled(i) == 1
                aux_X = [aux_X, X(i)];
                aux_Y = [aux_Y, Y(i)];
            end
        end
        h = scatter(aux_Y, aux_X, 'MarkerEdgeColor', 'b', ...
            'MarkerFaceColor', [0.43, 0.8, 0.72]);
    end
    s = scatter(Y, X, 'MarkerFaceColor', 'none');
    f.Children.XColor = 'w';
    f.Children.YColor = 'w';
    f.Color = [1 1 1];
    set(s, 'ButtonDownFcn', {@click_fcn, Y, X, names, N});
    set(f, 'ButtonDownFcn', {@fig_remove_click_fcn});
    set(im, 'ButtonDownFcn', {@remove_click_fcn});
    ylim([-116.4, 104.4])
    t = text(s.Parent, 0, 0, '');
    hold off
    f.Visible = 'on';
    f.Position = [f.Position(1), f.Position(2), f.Position(4), ...
        f.Position(4)];
    f.Children.Position(1) = 0.11;
    f.Children.Position(3) = 0.78;
end
   

%% click_fcn
% This function shows the name of a channel when it is clicked.

function click_fcn(varargin)
    s = varargin{1};
    ax = s.Parent;
    t = ax.Children(1);
    aux = varargin{2};
    X = varargin{3};
    Y = varargin{4};
    names = varargin{5};
    N = varargin{end};
    check = 0;
	for i = 1:N
        if abs(aux.IntersectionPoint(1) - X(i)) < 0.001 && ...
                abs(aux.IntersectionPoint(2) - Y(i)) < 0.001
            t.String = names{i};
            t.Position = [X(i)+1, Y(i)-3, 0];
            check = 1;
            break;
        end
    end
    if check == 0
        t.String = '';
    end
end


%% remove_click_fcn
% This function removes the channel text from the figure when the head area
% is clicked.

function remove_click_fcn(varargin)
    f = varargin{1};
    ax = f.Parent;
    t = ax.Children(1);
    t.String = '';
end


%% fig_remove_click_fcn
% This function removes the channel text from the figure when the figure is
% clicked.

function fig_remove_click_fcn(varargin)
    f = varargin{1};
    ax = f.Children(1);
    t = ax.Children(1);
    t.String = '';
end