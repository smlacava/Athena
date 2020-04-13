%% u_test
% This function computes the Mann-Whitney-Wicoxon's analysis between a
% pattern of two different groups of subjects and, if required, it gives in 
% output a matrix which can be used for other statistical analysis or 
% classification analysis with other software applications
% 
% [P, Psig, data_sig] = t_test(first_group, second_group, label, ...
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

    P = ranksum(first_group, second_group);
    if nargin > 2
        Psig = [];
        data_sig = [];
        if P < alpha
        	diff = mean(first_group)-mean(second_group);
            data_sig = [first_group; second_group];
            if diff > 0
            	Psig = strcat(label, " major in ", first_name);
            else
            	Psig = strcat(label, " major in ", second_name);
            end
        end
    end
end