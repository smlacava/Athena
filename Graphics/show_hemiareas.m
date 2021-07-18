%% show_hemiareas
% This functionshows the locations of the frontal, central, temporal,
% parietal and occipital areas, either in the right or in the left 
% hemisphere, and eventually highlights some of them.
%
% f = show_hemiareas(hemiareas_list, title, hemiareas_list2)
%
% Input:
%   hemiareas_list is the string array containing the names of the areas
%       which have to be highlighted (empty vector by default)
%   title is the name of the resulting figure ('Hemiareas locations' by
%       default)
%   hemiareas_list2 is the string array containing the names of the areas
%       which have to be highlighted with a second color (empty vector by 
%       default)
%
% Output:
%   f is the handle to the resulting figure

function f = show_hemiareas(hemiareas_list, title, hemiareas_list2)
    if nargin < 1
        hemiareas_list = [];
    end
    if nargin < 2
        title = 'Areas locations';
    end
    if nargin < 3
        hemiareas_list2 = [];
    end
    filename = strcat(path_check(limit_path(mfilename('fullpath'), ...
        'Graphics')), 'docs', filesep, 'head.png');
    head = imread(filename);
    f = figure('Visible', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'name', title, 'NumberTitle','off');
    axis([-110.4, 110.4, -112,  100]);
    set(gca,'XColor', 'none','YColor','none')
    im = image([-110.4, 110.4], [-112,  100], head);
    hold on
    
    names = {'RightFrontal', 'LeftFrontal', 'RightCentral', ...
        'LeftCentral', 'RightTemporal', 'LeftTemporal', ...
        'RightParietal', 'LeftParietal', 'RightOccipital', ...
        'LeftOccipital'};
    % frontal R, frontal L, central R, central L, temporal R, temporal L, 
    % parietal R, parietal L, occipital R, occipital L
    X = [-49.2972; -49.2972; -3.9120; -3.9120; 0; 0; 30; 30; ...
        62.9914; 62.9914];
    Y = [20; -20; 20; -20; 80.41; -80.41; 20; -20; 20; -20];
    N = length(X);
    
    sigX = [];
    sigY = [];
    if not(isempty(hemiareas_list))
        for i = 1:length(hemiareas_list)
            [sigX, sigY] = add_hemiarea(sigX, sigY, hemiareas_list(i));
        end
        if not(isempty(sigX))
            h = scatter(sigY, sigX, 'MarkerEdgeColor', 'b', ...
                'MarkerFaceColor', [0.43, 0.8, 0.72]);
        end
    end
    
    sigX = [];
    sigY = [];
    if not(isempty(hemiareas_list2))
        for i = 1:length(hemiareas_list2)
            [sigX, sigY] = add_hemiarea(sigX, sigY, hemiareas_list2(i));
        end
        if not(isempty(sigX))
            h2 = scatter(sigY, sigX, 'MarkerEdgeColor', 'b', ...
                'MarkerFaceColor', [1, 0.2, 0]);
        end
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
            Xpos = X(i)+1;
            t.Position = [X(i)+2, Y(i)-6, 0];
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


%% add_hemiarea
% This function adds the coordinates of the searched hemiarea to the 
% related arrays.

function [sigX, sigY] = add_hemiarea(sigX, sigY, hemiarea)
    if strcmpi(hemiarea, 'RightFrontal')
        sigX = [sigX, -49.2972];
        sigY = [sigY, 20];
    elseif strcmpi(hemiarea, 'LeftFrontal')
        sigX = [sigX, -49.2972];
        sigY = [sigY, -20];
    elseif strcmpi(hemiarea, 'RightCentral')
        sigX = [sigX, -3.9120];
        sigY = [sigY, 20];
    elseif strcmpi(hemiarea, 'LeftCentral')
        sigX = [sigX, -3.9120];
        sigY = [sigY, -20];
    elseif strcmpi(hemiarea, 'RightTemporal')
        sigX = [sigX, 0];
        sigY = [sigY, 80.41];
    elseif strcmpi(hemiarea, 'LeftTemporal')
        sigX = [sigX, 0];
        sigY = [sigY, -80.41];
    elseif strcmpi(hemiarea, 'RightParietal')
        sigX = [sigX, 30];
        sigY = [sigY, 20];
    elseif strcmpi(hemiarea, 'LeftParietal')
        sigX = [sigX, 30];
        sigY = [sigY, -20];
    elseif strcmpi(hemiarea, 'RightOccipital')
        sigX = [sigX, 62.9914];
        sigY = [sigY, 20];
    else
        sigX = [sigX, 62.9914];
        sigY = [sigY, -20];
    end
end