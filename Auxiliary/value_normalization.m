%% value_normalization
% This function is is used to normalize a data vector or a data matrix.
%
% measure = value_normalization(measure, normalization)
%
% Input:
%   measure is the data matrix or data vector which has to be normalized
%       (in case of zscore normalization, it will be considered as a flat
%       vector)
%   normalization is the name of the normalization which has to be applied
%       on data, between 'zscore' (subtraction of the mean and division for
%       the standard deviation), 'max' (division for the maximum), 'minmax'
%       (subtraction of the minimum and division for the maximum minus the
%       minimum), no normalization otherwise (no normalization by default)


function measure = value_normalization(measure, normalization)
    if nargin < 2
        normalization = 'none';
    end
    
    if strcmpi(normalization, 'zscore')
        m = mean(measure(:));
        s = std(measure(:));
        measure = (measure-m)./s;
    elseif strcmpi(normalization, 'minmax')
        min_n = min(measure(:));
        max_n = max(measure(:));
        measure = (measure-min_n)./(max_n-min_n);
    elseif strcmpi(normalization, 'max')
        max_n = max(measure(:));
        measure = measure./max_n;
    end
end