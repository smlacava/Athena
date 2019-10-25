%% alpha_levelling
% This function computes the alpha level according to the conservativeness.
% It is used for correlations and statistical analysis.
% 
% [alpha] = alpha_levelling(cons, varargin)
%
% input:
%   cons is the level of conservativeness which determinates the
%       significativity of any difference (0=no conservativeness [default],
%       1=max conservativeness)
%   varargin is used to input the values used that determine the reduction
%       of the alpha level, such as the number of frequency bands or the
%       number of locations analyzed
%
% output:
%   alpha is the computed alpha level

function [alpha] = alpha_levelling(cons, varargin)
    alpha=0.05;
    if cons==1
        for i=1:length(varargin)
            alpha=alpha/varargin{i};
        end
    end
end

