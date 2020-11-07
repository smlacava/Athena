%% information
% This function is used to communicate some information to the user.
%
% f = information(message, title)
%
% Input:
%   message is the description of the information
%   title is the title of the figure (optional, '' by default)
%   okFLAG has to be 1 in order to set a button which allows the user to 
%       close the figure, 0 otherwise (1 by default)
%
% Output:
%   f is the handle to the figure


function f = information(message, title, okFLAG)
    if nargin < 2
        title = '';
    end
    if nargin < 3
        okFLAG = 1;
    end
    
    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    f = figure;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    im = imread('logo.png');
    set(f, 'Position', [200 350 300 150], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', title, 'Visible', 'off', ...
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
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.98 0.3 0.02], 'String', '', ...
        'FontUnits', 'normalized', ...
        'BackgroundColor', fgc, 'ForegroundColor', 'k');
    if okFLAG == 1
        hok = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
            'FontWeight', 'bold', 'Units', 'normalized', ...
            'Position', [0.35 0.05 0.3 0.25], 'Callback', 'close', ...
            'ForegroundColor', fgc, 'BackgroundColor', btn); 
        set(f, 'KeyPressFcn', {@enter_key_pressed});
    end
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    if okFLAG == 1
        waitfor(hok);
    end
end


%% enter_key_pressed
% This function closes the interface if the return key is used.

function enter_key_pressed(varargin)
    if strcmpi(varargin{2}.Key, 'return')
        close(varargin{1})
    end
end
