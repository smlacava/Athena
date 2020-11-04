%% discretized_entropy
% This function computes the discretized entropy of a time series, based of
% the Freedman-Diaconis rule.
%
% de = discretized_entropy(data)
%
% Input:
%   data is the (1 x samples) time series matrix
%
% Output:
%   de is the discretized entropy value

function de = discretized_entropy(data)
    L = length(data);
    
    range = max(data(:)) - min(data(:));
    points = ceil(range/(2.0*iqr(data).*L^(-1/3)));
    
    hdat = hist(data(:), points);
    hdat = hdat./sum(hdat);
    de = -sum(hdat.*log2(hdat+eps));
end