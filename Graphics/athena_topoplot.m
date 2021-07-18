%% athena_topoplot
% This function shows a topographic map of a scalp data field by 
% interpolating on a cartesian grid, and/or the channel locations, 
% eventually highlighting some of them (up to two highlighting colors).
%
% athena_topoplot(values, chanlocs, highlighted, second_highlighted, ...
%       channels_plot, contour_plot, clickable)
%
% Input:
%   values is the array of channels values, containing the value related
%       to each channel which has to be used for the interpolation
%   chanlocs is the structure containing information about the channels,
%       providing at least a labels field related to each channel's name,
%       and a set of fields containing the coordinates in a cartesian (X
%       and Y), spherical (sph_theta, sph_radius and sph_phi) or polar 
%       (theta and radius) representation.
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


function athena_topoplot(values, chanlocs, highlighted, ...
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
    
    head_rad = 0.5;          % actual head radius
    grid_scale = 67;         % plot map on a 67X67 grid
    circle_grid   = 201;     % number of angles to use in drawing circles
    head_color = [0 0 0];    % default head color (black)
    line_width = 1.7;        % default linewidth for head, nose, ears
    blanking_width = 0.035;  % width of the blanking ring
    head_width = 0.007;      % width of the cartoon head ring
    plotrad = 0.6;
    values = double(values(:));
    contour_level = 6;
    head_factor = 1.05;      % do not leave room for external ears
    points_size = 8;         % size of the points representing the channels
    
    %% Read channel location
    chanlocs = channels_locations(chanlocs);
    labels = {chanlocs.labels};
    theta = [chanlocs.theta];
    radius = [chanlocs.radius];
    theta = pi/180*theta;
    [x,y] = pol2cart(theta, radius);
    
    allchansind = 1:length(theta);
    plotchans = invalid_idxs(values, chanlocs);
   
    allchansind = allchansind(plotchans);
    radius = radius(plotchans);
    x = x(plotchans);
    y = y(plotchans);
    labels = char(labels(plotchans));
    values = values(plotchans);
    intrad = min(1.0,max(radius)*1.02);
    
    %% Find plotting channels
    pltchans = find(radius <= plotrad); % plot channels inside plotting circle
    intchans = find(x <= intrad & y <= intrad); % interpolate and plot channels inside interpolation square
    
    %% Eliminate channels not plotted
    intx = x(intchans);
    inty = y(intchans);
    x = x(pltchans);
    y = y(pltchans);
    
    intValues = values(intchans);    
    labels = labels(pltchans,:);
    
    %% Squeeze channel locations to <= headrad
    squeezefac = head_rad/plotrad;
    intx = intx*squeezefac;
    inty = inty*squeezefac;
    x = x*squeezefac;
    y = y*squeezefac;
    
    %% create grid
    xmin = min(-head_rad, min(intx)); 
    xmax = max(head_rad, max(intx));
    ymin = min(-head_rad, min(inty)); 
    ymax = max(head_rad,max(inty));
    xi = linspace(xmin, xmax, grid_scale);   % x-axis description (row vector)
    yi = linspace(ymin, ymax, grid_scale);   % y-axis description (row vector)
    
    [Xi, Yi, Zi] = griddata(inty, intx, intValues, yi', xi, 'v4'); % interpolate data
    
    %% Mask out data outside the head
    mask = (sqrt(Xi.^2 + Yi.^2) <= head_rad); % mask outside the plotting circle
    Zi(mask == 0) = NaN;                  % mask non-plotting voxels with NaNs
    
    %% Scale the axes and make the plot
    N = 1;
    h = findobj('type','figure');
    if not(isempty(h))
        for i = 1:length(h)
            N = max([h(i).Number, N]);
        end
        N = N+1;
    end
    figure(N)
    fig = gcf;
    fig.Color = [1, 1, 1];
    cla  % clear current axis
    hold on
    h = gca; % uses current axes
    set(gca,'Xlim',[-head_rad head_rad]*head_factor, 'Ylim', ...
        [-head_rad head_rad]*head_factor);
    unsh = (grid_scale+1)/grid_scale;
    if contour_plot == 1
        handle = surface(Xi*unsh, Yi*unsh,zeros(size(Zi)), Zi, ...
            'EdgeColor' ,'none', 'FaceColor', 'interp');
        colormap('jet');
        contour(Xi, Yi, Zi, contour_level, 'k', 'hittest', 'off');
    end
    %% Plot filled ring to mask jagged grid boundary
    hwidth = head_width;                   % width of head ring
    hin  = squeezefac*head_rad*(1- hwidth/2);  % inner head ring radius
    
    rwidth = blanking_width*1.3;             % width of blanking outer ring
    rin    =  head_rad*(1-rwidth/2);              % inner ring radius
    if hin>rin
        rin = hin;                              % dont blank inside the head ring
    end
    
    circ = linspace(0,2*pi,circle_grid);
    rx = sin(circ);
    ry = cos(circ);
    ringx = [[rx(:)' rx(1) ]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
    ringy = [[ry(:)' ry(1) ]*(rin+rwidth)  [ry(:)' ry(1)]*rin];
    patch(ringx,ringy,0.01*ones(size(ringx)),get(gcf,'color'),'edgecolor','none','hittest','off'); 
    hold on
    
    %% Plot cartoon head, ears, nose
    headx = [[rx(:)' rx(1) ]*(hin+hwidth)  [rx(:)' rx(1)]*hin];
    heady = [[ry(:)' ry(1) ]*(hin+hwidth)  [ry(:)' ry(1)]*hin];
    head_plot(headx, heady, head_rad, plotrad, head_color, line_width);
    
    %% Mark electrode locations
    if channels_plot == 1
        hp2 = show_channels(x, y, points_size, highlighted, ...
            second_highlighted, labels, contour_plot, clickable);
    	if clickable == 1
            s = scatter3(y, x, 3*ones(size(x)), points_size, 'k', ...
                'MarkerFaceColor', 'none', 'LineWidth', 1, ...
                'MarkerFaceColor', 'none');
            set(s, 'ButtonDownFcn', {@click_fcn, y, x, labels, length(x)});
            set(fig, 'ButtonDownFcn', {@fig_remove_click_fcn});
            t = text(s.Parent, 0, 0, -2, '', 'Color', 'w', ...
                'FontWeight', 'Bold', 'FontSize', 10);
            tb1 = text(s.Parent, 0, 0, -3, '', 'Color', 'k', ...
                'FontWeight', 'Bold', 'FontSize', 10);
            tb2 = text(s.Parent, 0, 0, -3, '', 'Color', 'k', ...
                'FontWeight', 'Bold', 'FontSize', 10);
            tb3 = text(s.Parent, 0, 0, -3, '', 'Color', 'k', ...
                'FontWeight', 'Bold', 'FontSize', 10);
            tb4 = text(s.Parent, 0, 0, -3, '', 'Color', 'k', ...
                'FontWeight', 'Bold', 'FontSize', 10);         
            if exist('handle', 'var')
                set(handle, 'ButtonDownFcn', {@interp_remove_click_fcn});
            end
        end
    end
    axis off
    axis equal
end


%% head_plot
% This function plots the head, the nose ad the hears.

function head_plot(headx, heady, headrad, plotrad, head_color, line_width)
    patch(headx,heady,ones(size(headx)), head_color, 'edgecolor', head_color, 'hittest', 'off'); 
    hold on
    base  = headrad-0.0046;
    nose_width = 0.2*headrad;
    tip   = 1.15*headrad;
    nose_tip_width = 0.08*headrad;
    tip_round  = 0.01*headrad;
    q = 0.05; % ear lengthening
    sf = headrad/plotrad;
    
    noseX = [nose_width; nose_tip_width/2; 0; -nose_tip_width/2; ...
        -nose_width]*sf;
    noseY = [base; tip-tip_round; tip; tip-tip_round; base]*sf;
    noseZ = 2*ones(5, 1);
    
    %earX = [0.492, 0.510, 0.518, 0.5299, 0.5419, 0.54, 0.547, ...
    %    0.532, 0.510, 0.484]*sf;
    earX = [0.492, 0.495, 0.5, 0.51, 0.525, 0.5419, 0.54, 0.547, ...
        0.532, 0.510, 0.484]*sf;
    earY = [q+0.0555, q+0.06, q+0.0775, q+0.0783, q+0.0746, q+0.0555, -0.0055, ...
        -0.0932 -0.1313 -0.1384 -0.1199]*sf;
    earZ = 2*ones(size(earX));
    
    % nose
    plot3(noseX, noseY, noseZ, 'Color', head_color, ...
        'LineWidth', line_width, 'hittest', 'off');
    
    % left ear
    plot3(earX, earY, earZ, 'color', head_color, ...
        'LineWidth', line_width, 'hittest', 'off')
    
    % right ear
    plot3(-earX, earY, earZ, 'color', head_color, ...
        'LineWidth', line_width, 'hittest', 'off')
end


%% invalid_idxs
% This function returns the index related to each infinite or NaN values.

function plotchans = invalid_idxs(values, chanlocs)
    idxs = union(find(isnan(values)), find(isinf(values))); % NaN and Inf values
    for idx = 1:length(chanlocs)
        if isempty(chanlocs(idx).X) 
            idxs = [idxs idx];
        end
    end
    plotchans = abs(setdiff([1:length(chanlocs)], idxs));
end


%% select_highlighted
% This function returns the coordinates of the points representing the 
% channels which have to be higlighted.

function [xhl, yhl] = select_highlighted(highlighted, x, y, labels)
    xhl = [];
    yhl = [];
    L = size(labels, 1);
    H = size(highlighted, 2);
    highlighted = ['xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', highlighted];
    highlighted = char(highlighted);
    highlighted(1, :) = [];
    for i = 1:H
        for j = 1:L
            if strcmp(strtok(highlighted(i, :), ' '), ...
                    strtok(labels(j, :), ' '))
                xhl = [xhl, x(j)];
                yhl = [yhl, y(j)];
            end
        end
    end
end


%% show_channels
% This function shows the channels and highlights them, if required.

function hp2 = show_channels(x, y, points_size, highlighted, ...
    second_highlighted, labels, contour_plot, clickable)        
        
        
    hp2 = plot3(y, x, ones(size(x)), '.', 'Color', [0 0 0], ...
        'markersize', points_size, 'linewidth', 0.5, 'hittest', 'off');
    hold on
    
    if contour_plot == 0
        hl_color = [1, 0.2, 0.2];
        second_hl_color = [0.2, 0.2, 1];
    else
        hl_color = [1, 1, 1];
        second_hl_color = [0.5, 0, 1];
    end
    
    if not(isempty(highlighted))
        [xhl, yhl] = select_highlighted(highlighted, x, y, labels);
        hp3 = plot3(yhl, xhl, ones(size(xhl)), '.', 'Color', ...
            hl_color, 'markersize', points_size*2.5, 'linewidth', 0.5, ...
            'hittest', 'off');  
    end
    if not(isempty(second_highlighted))
        [xhl2, yhl2] = select_highlighted(second_highlighted, x, y, labels);
        hp4 = plot3(yhl2, xhl2, ones(size(xhl2)), '.', 'Color', ...
            second_hl_color, 'markersize', points_size*2.5, ...
            'linewidth', 0.5, 'hittest', 'off');  
    end
end



%% click_fcn
% This function shows the name of a channel when it is clicked.

function click_fcn(varargin)
    s = varargin{1};
    ax = s.Parent;
    t = ax.Children(5);
    tb1 = ax.Children(1);
    tb2 = ax.Children(2);
    tb3 = ax.Children(3);
    tb4 = ax.Children(4);
    aux = varargin{2};
    X = varargin{3};
    Y = varargin{4};
    names = varargin{5};
    N = varargin{end};
    check = 0;
    bord = 0.003;
	for i = 1:N
        if abs(aux.IntersectionPoint(1) - X(i)) < 0.001 && ...
                abs(aux.IntersectionPoint(2) - Y(i)) < 0.001
            t.String = names(i, :);
            tb1.String = names(i, :);
            tb2.String = names(i, :);
            tb3.String = names(i, :);
            tb4.String = names(i, :);
            if X(i) < 0
                xp = X(i)+0.01;
            else
                xp = X(i)-0.02;
            end
            if Y(i) < 0
                yp = Y(i)+0.02;
            else
                yp = Y(i)-0.02;
            end
            t.Position = [xp, yp, 4];
            tb1.Position = [xp+bord, yp+bord, 3];
            tb2.Position = [xp+bord, yp-bord, 3];
            tb3.Position = [xp-bord, yp+bord, 3];
            tb4.Position = [xp-bord, yp-bord, 3];
            check = 1;
            break;
        end
    end
    if check == 0
        t.String = '';
        tb1.String = '';
        tb2.String = '';
        tb3.String = '';
        tb4.String = '';
    end
end


%% fig_remove_click_fcn
% This function removes the channel text from the figure when the figure is
% clicked.

function fig_remove_click_fcn(varargin)
    f = varargin{1};
    ax = f.Children(1);
    t = ax.Children(5);
    tb1 = ax.Children(1);
    tb2 = ax.Children(2);
    tb3 = ax.Children(3);
    tb4 = ax.Children(4);
    t.String = '';
    tb1.String = '';
    tb2.String = '';
    tb3.String = '';
    tb4.String = '';
end


%% interp_remove_click_fcn
% This function removes the channel text from the figure when the contour
% representing the interpolation is clicked.

function interp_remove_click_fcn(varargin)
    handle = varargin{1};
    fig_remove_click_fcn(handle.Parent.Parent);
end