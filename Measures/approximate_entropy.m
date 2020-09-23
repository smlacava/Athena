%% approximate_entropy
% This function computes the approximate entropy of a time series (based on
% Picus et al., 1991: A regularity statistic for medical data analysis).
%
% se = approximate_entropy(data, m, r)
%
% Input:
%   data is the time series
%   m is the embedding dimension (its maximum value is the number of
%       samples of the time series minus 1, 2 by default)
%   r is the fraction of standard deviation of the time series, which have
%       to be used as tolerance (0.2 by default)
%
% Output:
%   ae is the sample entropy


function ae = approximate_entropy(data, m, r)
    if nargin < 2
        m = 2;
    end
    if nargin < 3
        r = 0.2;
    end
    
    if size(data, 1) > size(data, 2)
        data = data';
    end
    
    N = length(data);
    PHI = zeros(1,2);
    sigma = std(data);
    r = r*sigma;

    for j = 1:2
        m = m+j-1;
        C = zeros(1 ,N-m+1);
        
        matches = zeros(m, N-m+1);
        for i = 1:m
            matches(i, :) = data(i:N-m+i);
        end
    
        for i = 1:N-m+1
            dist = abs(matches - repmat(matches(:,i), 1, N-m+1));
            C(i) = sum(max(dist, [], 1) <= r)/(N-m+1);
        end

        PHI(j) = sum(log(C))/(N-m+1);
    end

    ae = PHI(1)-PHI(2);
end