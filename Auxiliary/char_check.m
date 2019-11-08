%% char_check
% This function returns a character array of the data in input.
%
% [strOUT] = char_check(dataIN)
%
% input:
%   dataIN is the data to convert in a character array 
%
% output:
%   charOUT is the character array of the input data

function [charOUT]=char_check(dataIN)
    if isnumeric(dataIN)
        dataIN=string(dataIN);
    else 
        charOUT=char(dataIN);
    end
end