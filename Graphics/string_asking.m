function [dataPath, f] = string_asking(definput, msg, title)
    dataPath = definput;
    f = figure;
    set(f, 'Position', [200 350 400 200], 'Color', [0.67 0.98 0.92], ...
        'MenuBar', 'none', 'Name', char(title), 'Visible', 'off', ...
        'NumberTitle', 'off');
    bc = [0.67 0.98 0.92];
    ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.5 0.8 0.4], 'String', char(msg), 'FontUnits', ...
        'normalized', 'FontSize', 0.2, ...
        'BackgroundColor', bc, 'ForegroundColor', 'k');
    he = uicontrol('style', 'edit', 'Units', 'normalized', ...
        'Position', [0.2 0.25 0.6 0.2], 'FontUnits', 'normalized', ...
        'FontSize', 0.3, 'ForegroundColor', 'k', ...
        'String', {char(definput)}, 'Callback',{@dataPath_Callback});
    hp = uicontrol('Style', 'pushbutton', 'String', 'Ok',...
        'Units', 'normalized', 'Position', [0.4 0.05 0.2 0.15], ...
        'Callback', 'close'); 
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(he)

    function dataPath_Callback(hObject,eventdata)
         dataPath = get(hObject, 'string');
    end
end