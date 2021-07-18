%% t_test
% This function computes the 2-sample t-test analysis between a
% pattern of two different groups of subjects and, if required, it gives in 
% output a matrix which can be used for other statistical analysis or 
% classification analysis with other software applications
% 
% [P, Psig, data_sig, T] = t_test(first_group, second_group, label, ...
%       first_name, second_name, alpha)
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
%   T is the test statistic


function [P, Psig, data_sig, T] = t_test(first_group, second_group, ...
    label, first_name, second_name, alpha)

    [H, P, ~, STATS] = ttest2(first_group, second_group, 'alpha', alpha);
    if isnan(P)
        [H, P, ~, STATS] = ttest2(first_group, second_group, 'alpha', alpha, ...
            'method', 'exact');
    end
    T = STATS.tstat;
    if nargin > 2
        Psig = [];
        data_sig = [];
        if H == 1
            first_mean = mean(first_group);
            second_mean = mean(second_group);
        	diff = first_mean-second_mean;
            data_sig = [first_group; second_group];
            med_text = strcat(" (", first_name, " mean = ", ...
                string(first_mean), ", ", second_name, " mean = ", ...
                string(second_mean), ")");
            if diff > 0
            	Psig = strcat(label, " higher in ", first_name, med_text);
            else
            	Psig = strcat(label, " higher in ", second_name, med_text);
            end
        end
    end
end