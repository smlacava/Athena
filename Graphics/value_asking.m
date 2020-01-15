function [answer] = value_asking(initialValue, title, msg, maxvalue)
    switch nargin
        case 0
            initialValue = 0;
            title = 'Insert value';
            msg = 'Insert the whished value';
            maxvalue = Inf;
        case 1
            title = 'Insert value';
            msg = 'Insert the whished value';
            maxvalue = Inf;
        case 2
            msg = 'Insert the whished value';
            maxvalue = Inf;
        case 3
            maxvalue = Inf;
    end
    definput = {int2str(initialValue)};
    
    if maxvalue ~= Inf
        msg = strcat(msg, " (the maximum value has to be ", ...
            string(maxvalue), ")");
    end
    
    answer = str2double(inputdlg(msg, title, [1 50], definput));
    while isnan(answer) || answer > maxvalue
        if isnan(answer)
            answer = str2double(inputdlg(...
                ["Only integer numbers can be inserted" + newline + ...
                msg], title, [1 50], definput));
        else
            answer = str2double(inputdlg(msg, title, [1 50], definput));
        end
    end   
end