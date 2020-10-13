%% file_asking
% This function generates an interface which allows to ask the user a file,
% also allowing to search it visually through the file search
%
% answer = file_asking(definput, title, msg)
%
% Input:
%   definput is the predefined string representing the default input ('es.
%       C:/User/filename' by default)
%   title is the title of the GUI ('Insert value' by default)
%   msg is the message which is shown by the GUI ('Insert the wished value'
%       by default
%
% Output:
%   answer is the file chosen by the user

function answer = file_asking(definput, title, msg)

    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    
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
    set(f, 'Position', [200 350 400 200], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', char(title), 'Visible', 'off', ...
        'NumberTitle', 'off');
    ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0.1 0.4 0.8 0.4], 'String', char(msg), ...
        'FontUnits', 'normalized', 'FontSize', 0.2, ...
        'BackgroundColor', bgc, 'ForegroundColor', 'k');
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.985 0.2 0.015], 'String', '', ...
        'FontUnits', 'normalized', ...
        'BackgroundColor', fgc, 'ForegroundColor', 'k');
    he = uicontrol('style', 'edit', 'Units', 'normalized', ...
        'Position', [0.1 0.3 0.7 0.2], 'FontUnits', 'normalized', ...
        'FontSize', 0.3, 'ForegroundColor', 'k', ...
        'String', {char(definput)});
    hp = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'BackgroundColor', btn, 'ForegroundColor', fgc, ...
        'Units', 'normalized', 'Position', [0.375 0.05 0.275 0.2], ...
        'Callback', {@ok_Callback}, 'FontWeight', 'bold'); 
    hfs = uicontrol('Style', 'pushbutton', 'String', '<<', ...
        'BackgroundColor', btn, 'Units', 'normalized', ...
        'Position', [0.8 0.3 0.1 0.205], 'ForegroundColor', fgc, ...
        'Callback', {@fileSearch_Callback}, 'FontWeight', 'bold'); 
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


%% inputCheck
% This function check if the file chosen by the user exists, and if it does
% not exist the predefined input is returned
%
% answer = inputCheck(value, definput)
% 
% Input:
%   value is the file chosen by the user
%   definput is the predefined input
% 
% Output:
%   answer is the name of the file if it exists, the predefined input
%       otherwise

function answer = inputCheck(value, definput)
    try
        value = value{1,1};
    catch
    end
    try
        definput = definput{1,1};
    catch
    end
    if not(exist(value, 'file'))
        answer = definput;
    else
        answer = value;
    end
end