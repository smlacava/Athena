%% show_areas
% This functionshows the locations of the frontal, central, temporal,
% parietal and occipital areas, and eventually highlights some of them.
%
% f = show_areas(areas_list, title)
%
% Input:
%   areas_list is the string array containing the names of the areas which
%       have to be highlighted (empty vector by default)
%   title is the name of the resulting figure ('Areas locations' by
%       default)
%
% Output:
%   f is the handle to the resulting figure

function f = show_areas(areas_list, title)
    if nargin < 1
        areas_list = [];
    end
    if nargin < 2
        title = 'Areas locations';
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
    
    names = {'Frontal', 'Central', 'Temporal', 'Temporal', 'Parietal', ...
        'Occipital'};
    % frontal, central, temporal(R), temporal(L), parietal, occipital
    X = [-49.2972; -3.9120; 0; 0; 18.6874; 62.9914];
    Y = [0; 0; 80.41; -80.41; 0; 0];
    N = length(X);
    
    sigX = [];
    sigY = [];
    if not(isempty(areas_list))
        for i = 1:length(areas_list)
            if strcmpi(areas_list(i), 'Frontal')
                sigX = [sigX, -49.2972];
                sigY = [sigY, 0];
            elseif strcmpi(areas_list(i), 'Central')
                sigX = [sigX, -3.9120];
                sigY = [sigY, 0];
            elseif strcmpi(areas_list(i), 'Temporal')
                sigX = [sigX, 0, 0];
                sigY = [sigY, 80.41, -80.41];
            elseif strcmpi(areas_list(i), 'Parietal')
                sigX = [sigX, 18.6874];
                sigY = [sigY, 0];
            else
                sigX = [sigX, 62.9914];
                sigY = [sigY, 0];
            end
        end
        if not(isempty(sigX))
            h = scatter(sigY, sigX, 'MarkerEdgeColor', 'b', ...
                'MarkerFaceColor', [0.43, 0.8, 0.72]);
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