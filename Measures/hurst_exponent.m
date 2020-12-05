%% hurst_exponent
% This function computes the hurst exponent related to a univariate time
% series.
%
% hurst = hurst_exponent(data)
%
% Input:
%   data is the array representing the time series
%
% Output:
%   hurst is the value of the hurst exponent


function hurst = hurst_exponent(data)
    nSamples = length(data);
    yvals = zeros(1, nSamples);
    xvals = yvals;
    aux_data = yvals;
    count = 1;
    binsize = 1;
    while nSamples > 4
        y = std(data);
        xvals(count) = binsize;
        yvals(count) = binsize*y;
        nSamples = bitshift(nSamples, -1);
        binsize = bitshift(binsize, 1);
        for i = 1:nSamples
            aux_data(i) = data(2*i)+data((2*i)-1);
        end
        data = aux_data(1:nSamples)/2;
        count = count+1;
    end

    xvals = xvals(1:count-1);
    yvals = yvals(1:count-1);
    logx = log(xvals);
    logy = log(yvals);
    p = polyfit(logx, logy, 1);
    hurst = p(1);
end