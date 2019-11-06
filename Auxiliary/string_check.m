%% string_check
% This function returns a string of the data in input.
%
% [strOUT] = string_check(dataIN)
%
% input:
%   dataIN is the data to convert in a string (returned as it is if it is
%       already a string)
%
% output:
%   strOUT is the string version of the input data

function [strOUT]=string_check(dataIN)
    if iscell(dataIN) || ischar(dataIN)
        strOUT=string(dataIN);
    else 
        strOUT=dataIN;
    end
end