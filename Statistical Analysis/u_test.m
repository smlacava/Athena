%% u_test
% This function computes the Mann-Whitney-Wicoxon's analysis between a
% pattern of two different groups of subjects and, if required, it gives in 
% output a matrix which can be used for other statistical analysis or 
% classification analysis with other software applications
% 
% [P, Psig, data_sig, U] = u_test(first_group, second_group, ...
%       label, first_name, second_name, alpha)
%
% Input:
%   first_group is the name of the file (with its directory) which contains
%   	the matrix subjects*bands*locations of the first group of subjects
%   second_group is the name of the file (with its directory) which 
%       contains the matrix subjects*bands*locations of the second group of 
%       subjects
%   label is the name of the parameter which has to be compared
%   first_name is the name of the first group of subjects
%   second_name is the name of the second group of subjects
%   alpha is the alpha value (if the p-value of a comparison is less than
%       this value, the comparison can be considered as significant)
%
% Output:
%   P is the p-value matrix
%   Psig gives information about the significant (empty if the comparison
%       is not significant)
%   dataSig is the matrix related to the measure of each subject in 
%       significant comparisons
%   U is a row vector which contains the test statistic for the first group
%       as first element, and the test statistic for the second group as 
%       second element


function [P, Psig, data_sig, U] = u_test(first_group, second_group, ...
    label, first_name, second_name, alpha)

    [P, H, STAT] = ranksum(first_group, second_group, 'alpha', alpha);
    if isnan(P)
        [P, H, STAT] = ranksum(first_group, second_group, 'alpha', alpha, ...
            'method', 'exact');
    end
    if nargin > 2
        Psig = [];
        data_sig = [];
        if H == 1
            first_median = median(first_group);
            second_median = median(second_group);
        	diff = first_median-second_median;
            data_sig = [first_group; second_group];
            med_text = strcat(" (", first_name, " median = ", ...
                string(first_median), ", ", second_name, " median = ", ...
                string(second_median), ")");
            if diff > 0
            	Psig = strcat(label, " higher in ", first_name, med_text);
            else
            	Psig = strcat(label, " higher in ", second_name, med_text);
            end
        end
    end
    if nargout > 3
        N1 = length(first_group);
        U1 = STAT.ranksum-((N1*(N1+1))/2);
        [P, ~, STAT] = ranksum(second_group, first_group, 'alpha', alpha);
        if isnan(P)
            [P, ~, STAT] = ranksum(second_group, first_group, 'alpha', ...
                alpha, 'method', 'exact');
        end
        N2 = length(second_group);
        U2 = STAT.ranksum-((N2*(N2+1))/2);
        U = [U1, U2];
    end
end