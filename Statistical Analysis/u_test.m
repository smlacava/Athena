%% u_test
% This function computes the Mann-Whitney-Wicoxon's analysis between a
% pattern of two different groups of subjects and, if required, it gives in 
% output a matrix which can be used for other statistical analysis or 
% classification analysis with other software applications
% 
% [P, Psig, data_sig] = u_test(first_group, second_group, label, ...
%       first_name, second_name, alpha)
%
% input:
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
% output:
%   P is the p-value matrix
%   Psig gives information about the significant (empty if the comparison
%       is not significant)
%   dataSig is the matrix related to the measure of each subject in 
%       significant comparisons


function [P, Psig, data_sig] = u_test(first_group, second_group, ...
    label, first_name, second_name, alpha)

    [P, H] = ranksum(first_group, second_group, 'alpha', alpha);
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
            	Psig = strcat(label, " major in ", first_name, med_text);
            else
            	Psig = strcat(label, " major in ", second_name, med_text);
            end
        end
    end
end