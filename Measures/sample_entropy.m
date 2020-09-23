%% sample_entropy
% This function computes the sample entropy of a time series, through the 
% Richman’s algorithm (Richman and Moorman, 2000: Physiological time-series 
% analysis using approximate entropy and sample entropy).
%
% se = sample_entropy(data, m, r)
%
% Input:
%   data is the time series
%   m is the embedding dimension (its maximum value is the number of
%       samples of the time series minus 1, 2 by default)
%   r is the fraction of standard deviation of the time series, which have
%       to be used as tolerance (0.2 by default)
%
% Output:
%   se is the sample entropy


function se = sample_entropy(data, m, r)
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
    sigma = std(data);
    r = r*sigma;
    
    matches = zeros(m+1, N);
    for i = 1:1:m+1
        matches(i, 1:N+1-i) = data(i:end);
    end
    matches = matches';

    distB = chebyshev_distance(matches(:, 1:m));
    if isempty(distB)
        se = log(N-m)+log(N-m-1)-log(2);
        return
    end
    
    distA = chebyshev_distance(matches(:, 1:m+1));
    B = sum(distB  <= r);
    A = sum(distA <= r);
        
    if B == 0 % not defined
        se = NaN;
    elseif A == 0 % lower limit
        se = 0;
    else
        se = -log((A/B)*((N-m+1)/(N-m-1))); 
    end
        
    if isinf(se) % upper limit
      	se = log(N-m)+log(N-m-1)-log(2);
    end
end