%% ind_corr_glob_conn
% This function is used to compute the correlation between an index and a 
% global connectivity measure.
%
% [RHO, P, RHOsig] = ind_corr_glob_conn(data, Ind, cons, measure, sub)
%
% input:
%   data is a matrix which contains the values of the measure to correlate
%       for each subject
%   Ind is the index to correlate of each subject
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

function [RHO, P, RHOsig] = ind_corr_glob_conn(data, Ind, cons, ...
    measure, sub)

    nLoc = size(data,3);
    Ind = Ind(:, end);
    
    if length(size(data)) == 4    
        nBands = size(data, 2);
        data_glob = squeeze(sum(data, [3 4])/(nLoc*nLoc-nLoc));
        P = zeros(nBands, 1);
        RHO = P;
        RHOsig = [string() string()];
        alpha = alpha_levelling(cons, nBands);
        
        for i = 1:nBands
        	[RHO(i, 1), P(i, 1)] = corr(Ind, data_glob(:, i), 'type', ...
                'Spearman');
            if P(i, 1) < alpha
                RHOsig = [RHOsig; ...
                    strcat('Band', string(i)), string(RHO(i, 1))];
                correlation(Ind, data_glob(:, i), ...
                    strcat('Global, Band ', string(i)), 'Index', ...
                    measure, sub);
            end
        end            
        RHOsig(1, :) = [];
    else
        data_glob = sum(data, [2 3])/(nLoc*nLoc-nLoc);
        RHOsig = [];
        
        alpha = alpha_levelling(cons);
        
        [RHO, P] = corr(Ind, data_glob, 'type', 'Spearman');

        if P < alpha
        	RHOsig = string(RHO);
            correlation(Ind, data_glob, 'Global', 'Index', measure, sub);
        end
    end
end