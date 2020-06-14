%% patient_check
% This function check if a subject belongs to the first group of subjects
%
% group = patient_check(group_var, patient_group_name)
%
% input:
%   group_var is a string or an integer which represents the group to
%       which it belongs
%   patient_group_name is the name of the first group of subjects (HC by
%       default)
%
% output:
%   group is true if the subject is a patient and false if it is an
%       healthy control

function [group] = patient_check(group_var, patient_group_name)
    if nargin == 1
        patient_group_name = "HC";
    end
    group = false;
    if strcmpi(char_check(group_var), patient_group_name)
        group = true;
    end
end
            
     