%% problem
% This function is used to communicate a problem to the user
%
% problem(message)
%
% Input:
%   message is the description of the problem


function problem(message)
    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    f = figure;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    im = imread('logo.png');
    set(f, 'Position', [200 350 300 150], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', 'Problem', 'Visible', 'off', ...
        'NumberTitle', 'off');
    axes('pos', [0 0.4 0.25 0.46])
    imshow('logo.png')
    text_pos = [0.25 0.4 0.75 0.5];
    if length(message) < 90
        text_pos(2) = 0.3;
    end
    ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', text_pos, 'String', message, ...
        'FontUnits', 'normalized', 'FontSize', 0.215, ...
        'BackgroundColor', bgc, 'ForegroundColor', 'k', ...
        'horizontalAlignment', 'left');
    hok = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'FontWeight', 'bold', 'Units', 'normalized', ...
        'Position', [0.35 0.05 0.3 0.25], 'Callback', 'close', ...
        'ForegroundColor', fgc, 'BackgroundColor', btn); 
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.98 0.3 0.02], 'String', '', ...
        'FontUnits', 'normalized', ...
        'BackgroundColor', fgc, 'ForegroundColor', 'k');
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(hok);
end