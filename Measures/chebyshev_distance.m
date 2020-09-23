%% chebyshev_distance
% This function computes the Chebyshev distance of points contained in a
% matrix.
%
% dist = chebyshev_distance(data)
%
% Input:
%   data is the (points x dimensions) data matrix which contains the points
%       which have to be evaluated in computing the distances
%
% Output:
%   dist is the array which contains the Chebyshev distances, structured as
%       [d12, d13, d14, ..., d1n, d23, d24, ..., d2n, d34, ...], where dij
%       refers to the distance between the point i and the point j (note
%       that the distances already computed are not repeated, for example
%       since the distance d12 is computed, the distance d21 is not
%       included in the array)


function dist = chebyshev_distance(data)
    [n, dimension] = size(data);
    dist = zeros(1, n*(n-1)/2);
    k = 1;
    for i = 1:n-1
        dmax = zeros(n-i, 1);
        for dim = 1:dimension
            dmax = max(dmax, abs(data(i, dim) - data((i+1):n, dim)));
        end
        dist(k:(k+n-i-1)) = dmax;
        k = k + (n-i);  
        pause(n/10000000)
    end
end