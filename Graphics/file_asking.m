function [answer] = file_asking(definput, title, msg)
    switch nargin
        case 0 
            definput = {'es. C:/User/filename'};
            title = 'Insert value';
            msg = 'Insert the whished value';
        case 1
            title = 'Insert value';
            msg = 'Insert the whished value';
        case 2
            msg = 'Insert the whished value';
    end
    answer = false;
    check = definput;
    f = figure;
    set(f, 'Position', [200 350 400 200], 'Color', [0.67 0.98 0.92], ...
        'MenuBar', 'none', 'Name', char(title), 'Visible', 'off', ...
        'NumberTitle', 'off');
    bc = [0.67 0.98 0.92];
    button_bc = [0.25 0.96 0.82];
    button_fc = [0.05 0.02 0.8];
    ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.5 0.8 0.4], 'String', char(msg), 'FontUnits', ...
        'normalized', 'FontSize', 0.2, ...
        'BackgroundColor', bc, 'ForegroundColor', 'k');
    he = uicontrol('style', 'edit', 'Units', 'normalized', ...
        'Position', [0.2 0.25 0.6 0.2], 'FontUnits', 'normalized', ...
        'FontSize', 0.3, 'ForegroundColor', 'k', ...
        'String', {char(definput)});
    hp = uicontrol('Style', 'pushbutton', 'String', 'Ok', ...
        'BackgroundColor', button_bc, 'ForegroundColor', button_fc, ...
        'Units', 'normalized', 'Position', [0.4 0.05 0.2 0.15], ...
        'Callback', {@ok_Callback}); 
    hfs = uicontrol('Style', 'pushbutton', 'String', '<<', ...
        'BackgroundColor', button_bc, 'Units', 'normalized', ...
        'Position', [0.8 0.25 0.1 0.2], 'ForegroundColor', button_fc, ...
        'Callback', {@fileSearch_Callback}); 
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(he)

    function ok_Callback(~, ~)
    	answer = inputCheck(he.String, definput);
        close
    end
    function fileSearch_Callback(~, ~)
        [i, ip] = uigetfile;
        if i ~= 0
            he.String = inputCheck(strcat(string(ip), string(i)), ...
                definput);
        end
    end
end

function answer = inputCheck(value, definput)
    try
        value = value{1,1};
    catch
    end
    try
        definput = definput{1,1};
    catch
    end
    if strcmp(value, definput)
        answer = definput;
    else
        answer = value;
    end
end