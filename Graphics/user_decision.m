%% user_decision
% This function is used to ask the user if he/she wants to compute an
% action
%
% answer = user_decision(msg, title)
%
% Input:
%   msg is the message which has to be showed
%   title is the title of the image


function [answer] = user_decision(msg, title)
    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    answer = 'no';
    f = figure;
    set(f, 'Position', [200 350 400 200], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', char(title), 'Visible', 'off', ...
        'NumberTitle', 'off');
    ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.45 0.8 0.4], 'String', char(msg), ...
        'FontUnits', 'normalized', 'FontSize', 0.2, ...
        'BackgroundColor', bgc, 'ForegroundColor', 'k');
    hok = uicontrol('Style', 'pushbutton', 'String', 'yes',...
        'Units', 'normalized', 'Position', [0.2 0.05 0.25 0.2], ...
        'Callback', {@ok_Callback}, 'BackgroundColor', btn, ...
        'ForegroundColor', fgc); 
    hno = uicontrol('Style', 'pushbutton', 'String', 'no',...
        'Units', 'normalized', 'Position', [0.6 0.05 0.25 0.2], ...
        'Callback', {@no_Callback}, 'BackgroundColor', btn, ...
        'ForegroundColor', fgc); 
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.985 0.2 0.015], 'String', '', ...
        'FontUnits', 'normalized', ...
        'BackgroundColor', fgc, 'ForegroundColor', 'k');
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(hno)
    
    function ok_Callback(hObject, eventdata)
         answer = 'yes';
         no_Callback(hObject, eventdata)
    end

    function no_Callback(hObject, eventdata)
        close(f)
    end
end