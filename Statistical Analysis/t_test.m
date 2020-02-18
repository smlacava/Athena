%% mult_t_test
% This function computes the Wicox's analysis between patterns of 2
% different groups. If required, it gives in output a matrix which can be
% used for another statistical analysis or a classification with another
% software.
% 
% [P, Psig, locList, data] = mult_t_test(group1, group2, locations, ...
%     connCheck, studyType, cons)
%
% input:
%   group1 is the name of the file (with its directory) which contains the
%   	matrix subjects*bands*locations of the first group of subjects
%   group2 is the name of the file (with its directory) which contains the
%       matrix subjects*bands*locations of the second group of subjects
%   locFile is the name of the file (with its directry) which contains
%       the matrix of the channels or the ROIs (in the first column)
%   connCheck is a check which indicates if the measure to test is a
%       connectivity measure (connCheck=1) or not (connCheck=0)
%   studyType is the type of the statistical study (total [default], areas,
%        asymmetry or global)
%   cons is the level of conservativeness which determinates the
%       significativity of any difference (0=no conservativeness [default],
%       1=max conservativeness)
%
% output:
%   P is the p-value matrix
%   Psig is the significativity matrix
%   locList is the list of the tested areas
%   data is the (optional) output matrix subjects*(bands*locations) useful
%       for external analysis (for example, other statistical analysis,
%       correlation analysis or classification)
%   dataSig is the matrix related to the measure of each subject in 
%       significant comparisons

function [P, Psig, data_sig] = t_test(first_group, second_group, ...
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