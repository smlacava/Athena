function [answer] = user_decision(msg)
    answer = 0;
    if nargin == 0
        msg = 'We found some problems, Do you want to continue?';
    end
    im = imread('untitled3.png');
    h = msgbox(msg, 'Error', 'custom', im);
    yes = uicontrol('Parent', h, 'Style','pushbutton', 'String', 'YES', ...
        'Callback', @pushbuttonYES_callback);
    no = uicontrol('Parent', h, 'Style','pushbutton', 'String', 'NO', ...
        'Callback', @pushbuttonNO_callback);
    set(h, 'color', [0.67 0.98 0.92])
end

function [answer] = pushbuttonYES_callback(src,event)
	answer = 1;
end
function [answer] = pushbuttonNO_callback(src,event)
	answer = 0;
end