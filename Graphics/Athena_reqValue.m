%% Athena_reqValue
% This function asks for an integer value to the user and returns the
% answer
%
% [answer] = Athena_reqValue(msg)
%
% input:
%   msg is the message to show in the dialogue box
%
% output:
%   answer is the value 

function [answer] = Athena_reqValue(msg)

    if nargin == 0
    	msg = 'Insert the value';
    end
    
    msg = {msg};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'0'};
    
    answer = inputdlg(msg,dlgtitle,dims,definput);
    answer = str2double(answer{1});
end
    