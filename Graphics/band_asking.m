function [fmin, fmax, check] = band_asking(fmin, fmax)
    if nargin == 0
        fmin = '0';
        fmax = 'Inf';
    else
        fmin = int2str(fmin);
        fmax = int2str(fmax);
    end

    f = figure;
    bgc = [0.67 0.98 0.92];
    fgc = [0.047 0.02 0.8];
    btn = [0.25 0.96 0.82];
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
        'Units', 'normalized', 'Position', [0.4 0.05 0.2 0.15], ...
        'Callback', {@ok_Callback}, 'ForegroundColor', fgc, ...
        'BackgroundColor', btn); 
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