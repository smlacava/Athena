%% ind_corr_glob
% This function is used to compute the correlation between an index and a
% global not-connectivity measure.
%
% [RHO, P, RHOsig] = ind_corr_glob(data, Ind, cons, measure, sub)
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

function [RHO, P, RHOsig] = ind_corr_glob(data, Ind, cons, measure, sub)

    Ind = Ind(:, end);
    if length(size(data)) == 3
        nBands = size(data, 2);
        
        P = zeros(nBands, 1);
        RHO = P;
        RHOsig = [string() string()];
        alpha = alpha_levelling(cons, nBands);
        
        for i = 1:nBands
            data_glob = squeeze(mean(data(:, i, :), 3));
            [RHO(i, 1), P(i, 1)] = corr(Ind, data_glob, 'type', 'Spearman');
            if P(i, 1) < alpha
                RHOsig = [RHOsig; strcat('Band', string(i)), ...
                    string(RHO(i, 1))];
                correlation(Ind, data_glob(:, i), ...
                    strcat('Global, Band ', string(i)), 'Index', ...
                    measure, sub);
            end
        end

    else
        RHOsig = string();
        alpha = alpha_levelling(cons);
        
        data_glob = squeeze(mean(data, 2));
        [RHO, P] = corr(Ind, data_glob, 'type', 'Spearman');
        if P < alpha
        	RHOsig = [RHOsig; string(RHO)];
            correlation(Ind, data_glob, 'Global', 'Index', measure, sub);
        end
    end
    RHOsig(1, :) = [];
end