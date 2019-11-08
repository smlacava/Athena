%% cons_check
% This function check the level of the conservativeness used to compute
% statistical and correlation analysis.
%
% consOUT = cons_check(consIN)
%
% input:
%   consIN is the chosen conservativeness level
%
% output:
%   consOUT is the conservativeness level, converted to a format usable by
%       the toolbox (the integer 0 in case of minimum conservativeness, 1
%       otherwise)

function [consOUT] = cons_check(consIN)
    if sum(strcmp(consIN, ["max", "Max", "MAX", "1"]))
        consOUT = 1;
    else
        consOUT = 0;
    end
end