%% ind_corr_tot
% This function is used to compute the correlation between an index and a 
% not-connettivity measure in each location.
%
% [RHO, P, RHOsig] = ind_corr_(data, Ind, locations, cons, measure, sub)
%
% input:
%   data is a matrix which contains the values of the measure to correlate
%       for each subject
%   Ind is the index to correlate of each subject
%   locations is an array which contains the names of each location
%   cons is the conservativeness level (0 = minumum, 1 = maximum)
%   measure is the name of the measure to correlate
%   sub is an array which contains the name of each subject
%
% output:
%   RHO is the matric which contains Spearman's correlation index of each 
%       area
%   P is the matrix which contains the p-value of each area
%   RHOsig is the matrix which contains information about the significant 
%       correlations

function [RHO, P, RHOsig] = ind_corr_tot(data, Ind, locations, cons, ...
    measure, sub)

    nLoc = length(locations);
    Ind = Ind(:, end);
    
    if length(size(data)) == 3     
        nBands = size(data, 2);
        
        P = zeros(nBands, nLoc);
        RHO = P;
        RHOsig = [string() string() string()];
        alpha = alpha_levelling(cons, nLoc, nBands);
        
        for i = 1:nBands
            for j = 1:nLoc
                [RHO(i, j), P(i, j)] = corr(Ind, data(:, i, j), 'type', ...
                    'Spearman');
                if P(i, j) < alpha
                    RHOsig = [RHOsig; string(i),locations(j), ...
                        string(RHO(i, j))];
                    correlation(Ind, data(:, i, j), ...
                        strcat(locations(j), ', Band ', string(i)), ...
                        'Index', measure, sub);
                end
            end
        end            
    else
        RHOsig = [string() string()];
        RHO = zeros(1, nLoc);
        P = RHO;
        alpha = alpha_levelling(cons, nLoc);

        for i = 1:nLoc
            [RHO(1, i), P(1, i)] = corr(Ind, data(:, i), 'type', ...
                'Spearman');
            if P(1, i) < alpha
                RHOsig = [RHOsig; locations(i) string(RHO(1, i))];
                correlation(Ind, data(:, i), string(locations(i)), ...
                    'Index', measure, sub);
            end
        end
    end
    RHOsig(1, :)=[];
end