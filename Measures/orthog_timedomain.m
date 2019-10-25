%% orthog_timedomain
% This funcion is used by the amplitude_envelope_correlation_orth function

function [Yorth]=orthog_timedomain(X,Y)
R=[ones(length(X),1) X] \ Y;
Ypred=X*R(2);
Yorth=Y-Ypred;