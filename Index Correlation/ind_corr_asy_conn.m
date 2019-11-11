%% ind_corr_asy_conn
% This function is used to compute the correlation between an index and the
% asymmetry of a connectivity measure.
%
% [RHO, P, RHOsig] = ind_corr_areas_conn(data, Ind, RightLoc, LeftLoc, ...
%     cons, measure, sub)
%
% input:
%   data is a matrix which contains the values of the measure to correlate
%       for each subject
%   Ind is the index to correlate of each subject
%   RightLoc is an array which contains all the indexes of the right 
%       locations
%   LeftLoc is an array which contains all the indexes of the left 
%       locations
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

function [RHO, P, RHOsig] = ind_corr_asy_conn(data, Ind, RightLoc, ...
    LeftLoc, cons, measure, sub)
    R = length(RightLoc);
    R = R*R-R;
    L = length(LeftLoc);
    L = L*L-L;
    Ind = Ind(:, end);
    if length(size(data)) == 4
        nBands = size(data, 2);
        data_asy = zeros(size(data, 1), nBands, 2);
        data_asy(:, :, 1) = sum(squeeze(sum( ...
            data(:, :, RightLoc, RightLoc), 3)), 3)/R;
        data_asy(:, :, 2) = sum(squeeze(sum( ...
            data(:, :, LeftLoc, LeftLoc), 3)), 3)/L;

        P = zeros(nBands, 1);
        RHO = P;
        RHOsig = [string() string()];
        alpha = alpha_levelling(cons, nBands);
        
        for i = 1:nBands
            asy = abs(data_asy(:, i, 1)-data_asy(:, i, 2));
            [RHO(i, 1), P(i, 1)] = corr(Ind, asy, 'type', 'Spearman');
            if P(i, 1) < alpha
                RHOsig = [RHOsig; strcat('Band', string(i)), ...
                    string(RHO(i, 1))];  
                correlation(Ind, asy, ...
                    strcat('Asymmetry, Band ', string(i)), 'Index', ...
                    measure, sub);
            end
        end

    else
        data_asy = zeros(size(data, 1), 2);
        data_asy(:, 1) = sum(squeeze(sum( ...
            data(:, RightLoc, RightLoc), 2)), 2)/R;
        data_asy(:, 2) = sum(squeeze(sum( ...
            data(:, LeftLoc, LeftLoc), 2)), 2)/L;

        RHOsig = string();
        alpha = alpha_levelling(cons);
        
        asy = abs(data_asy(:, 1)-data_asy(:, 2));
        [RHO, P] = corr(Ind, asy, 'type', 'Spearman');
        if P < alpha
        	RHOsig = [RHOsig; string(RHO)];
            correlation(Ind, tot, strcat('Asymmetry'), 'Index', ...
                measure, sub);         
        end
    end
    RHOsig(1, :) = [];
end