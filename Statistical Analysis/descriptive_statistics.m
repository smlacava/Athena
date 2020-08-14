%% descriptive_statistics
% This function computes the descriptive statistical analysis on a vector,
% giving as result its mean, its median, its variance, its maximum value,
% its minimum value, the kurtosis value and the skewness value
%
% [mean_value, median_value, variance_value, max_value, min_value, ...
%       kurtosis_value, skewness_value] = descriptive_statistics(data)
%
% Input:
%   data is the data vector of which compute the descriptive statistical
%       analysis
%
% Output:
%   mean_value is the mean of the values of the data vector
%   median_value is the median of the values of the data vector
%   variance_value is the variance of the values of the data vector
%   max_value is the maximum of the values of the data vector
%   min_value is the minimum of the values of the data vector
%   kurtosis_value is the sample kurtosis of the values of the data vector
%       (the fourth central moment of the data vector, divided by fourth 
%       power of its standard deviation)
%   skewness_value is the sample skewness of the values of the data vector
%       (the third central moment of the data vector, divided by tge cube
%       of its standard deviation)


function [mean_value, median_value, variance_value, max_value, ...
    min_value, kurtosis_value, skewness_value] = ...
    descriptive_statistics(data)

    mean_value = mean(data);
    median_value = median(data);
    variance_value = var(data);
    max_value = max(data);
    min_value = min(data);
    
    N = length(data);
    norm_var = var(data, 1);
    norm_data = data-mean_value;
    kurtosis_value = (sum((norm_data).^4)./N)./(norm_var.^2);
    skewness_value = (sum((norm_data).^3)./N)./(norm_var.^1.5);
end
    