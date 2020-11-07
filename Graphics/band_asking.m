%% band_asking
% This function returns the chosen cut frequencies values
% 
% [fmin, fmax, check] = band_asking(fmin, fmax)
%
% Input:
%   fmin is the value related to the lower cut frequency (0 by default)
%   fmax is the value related to the higher cut frequency (Inf by default)
%
% Output:
%   fmin is the value related to the lower cut frequency chosen by the user
%   fmax is the value related to the higher cut frequency chosen by the
%       user
%   check is 1 if the 'ok' button has been pushed, 0 otherwise

function [fmin, fmax, check] = band_asking(fmin, fmax)
    if nargin == 0
        fmin = '0';
        fmax = 'Inf';
    else
        fmin = string(fmin);
        fmax = string(fmax);
    end
    
    if nargin < 3
        fNyq = [];
    else
        fNyq = fs/2;
    end

    f = figure;
    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    check = 0;
    msg = {'Choose the frequency band you want to show, ',
        'and eventually to save (lower cut frequency and ',
        'higher cut frequecy, respectively)'};
    
    set(f, 'Position', [200 350 400 200], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', 'Frequency Band', 'Visible', 'off', ...
        'NumberTitle', 'off');
    ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.5 0.8 0.4], 'String', msg, 'FontUnits', ...
        'normalized', 'FontSize', 0.18, 'BackgroundColor', bgc, ...
        'ForegroundColor', 'k', 'horizontalAlignment', 'left');
    hmin = uicontrol('style', 'edit', 'Units', 'normalized', ...
        'Position', [0.1 0.25 0.3 0.2], 'FontUnits', 'normalized', ...
        'FontSize', 0.3, 'ForegroundColor', 'k', ...
        'String', {fmin}, 'Callback', {@fmin_Callback});
    hmax = uicontrol('style', 'edit', 'Units', 'normalized', ...
        'Position', [0.6 0.25 0.3 0.2], 'FontUnits', 'normalized', ...
        'FontSize', 0.3, 'ForegroundColor', 'k', ...
        'String', {fmax}, 'Callback', {@fmax_Callback});
    hok = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'FontWeight', 'bold', 'Units', 'normalized', ...
        'Position', [0.4 0.05 0.2 0.15], 'Callback', {@ok_Callback}, ...
        'ForegroundColor', fgc, 'BackgroundColor', btn); 
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.99 0.2 0.01], 'String', '', ...
        'FontUnits', 'normalized', ...
            'BackgroundColor', fgc, 'ForegroundColor', 'k');
    set(f, 'KeyPressFcn', {@enter_key_pressed});
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(hok);

    function fmin_Callback(hObject,eventdata)
         fmin = get(hObject, 'string');
         try
             fmin = fmin{1};                 
         catch
         end
    end

    function fmax_Callback(hObject,eventdata)
         fmax = get(hObject, 'string');
         try
             fmax = fmax{1};
         catch
         end
    end

    function ok_Callback(hObject,eventdata)
         check = 1;
         fmax = str2double(fmax);
         fmin = str2double(fmin);
         close(f);
    end
end



%% enter_key_pressed
% This function closes the interface if the return key is used.

function enter_key_pressed(varargin)
    if strcmpi(varargin{2}.Key, 'return')
        close(varargin{1})
    end
end