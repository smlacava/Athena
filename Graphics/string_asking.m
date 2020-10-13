%% string_asking
% This function asks a string value to the user through a GUI.
% 
% [string_value, f] = string_asking(definput, msg, title)
%
% Input:
%   definput is the predefined input string
%   msg is the message shown by the GUI
%   title is the title of the GUI
% 
% Output:
%   string_value is the string chosen by the user
%   f is the figure handle

function [dataPath, f] = string_asking(definput, msg, title)
    dataPath = definput;
    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    f = figure;
    set(f, 'Position', [200 350 400 200], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', char(title), 'Visible', 'off', ...
        'NumberTitle', 'off');
    ht = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', ...
        [0.1 0.5 0.8 0.4], 'String', char(msg), 'FontUnits', ...
        'normalized', 'FontSize', 0.2, ...
        'BackgroundColor', bgc, 'ForegroundColor', 'k');
    he = uicontrol('style', 'edit', 'Units', 'normalized', ...
        'Position', [0.1 0.3 0.8 0.2], 'FontUnits', 'normalized', ...
        'FontSize', 0.3, 'ForegroundColor', 'k', ...
        'String', {char(definput)}, 'Callback',{@dataPath_Callback});
    hp = uicontrol('Style', 'pushbutton', 'String', 'OK',...
        'Units', 'normalized', 'Position', [0.375 0.05 0.25 0.2], ...
        'Callback', 'close', 'BackgroundColor', btn, ...
        'ForegroundColor', fgc, 'FontWeight', 'bold'); 
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.99 0.2 0.01], 'String', '', ...
        'FontUnits', 'normalized', ...
        'BackgroundColor', fgc, 'ForegroundColor', 'k');
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(he)

    function dataPath_Callback(hObject,eventdata)
         dataPath = get(hObject, 'string');
    end
end