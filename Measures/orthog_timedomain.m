%% orthog_timedomain
% This funcion is used by the amplitude_envelope_correlation_orth function.
%
% [Yorth] = orthog_timedomain(X, Y)
%
% input:
%   X is the time series related to a location
%   Y is the time series related to another location
%
% output:
%   Yorth is the orthogonalized time series

function [Yorth] = orthog_timedomain(X, Y)
    R = [ones(length(X), 1) X] \ Y;
    Ypred = X*R(2);
    Yorth = Y-Ypred;
end