%% value_asking
% This function is used to ask a value to the user
% 
% answer = value_asking(initialValue, title, msg, maxvalue)
%
% Input:
%   initialValue is the value initially shown by the interface
%   title is the title of the interface
%   msg is the message shown by the interface
%   maxvalue is the maximum possible value which can be inserted by the
%       user (Infinite by default)


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
    answer = inputCheck(string_asking(definput, msg, title));    
    
    while isnan(answer) || answer > maxvalue
        if answer > maxvalue
            answer = inputCheck(string_asking(definput, msg, title));
        else
            answer = inputCheck(string_asking(definput, ...
                ["Only integer numbers can be inserted" + newline + ...
                msg], title));
        end
    end   
end

function answer = inputCheck(value)
    value = value{1,1};
    answer = str2double(value);
end