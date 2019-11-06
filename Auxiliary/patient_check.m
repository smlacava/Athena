%% patient_check
% This function check if a subject is a patient or an healthy control.
% It returns true if it is a patient and false if it is an healthy control, 
% checking the string or the integer used as input.
%
% [group] = patient_check(group_var)
%
% input:
%   group_var is a string or an integer which represents the group to
%       which it belongs
%
% output:
%   group is true if the subject is a patient and false if it is an
%       healthy control

function [group] = patient_check(group_var)
    group = true;
    if sum(strcmp(string(group_var), ['0', 'hc', 'HC', 'CTRL', 'ctrl', ...
            'Ctrl', 'CONTROL', 'Control', 'control', 'healthy control', ...
            'Healthy Control', 'Healthy control', 'HEALTHY CONTROL', ...
            'Healthy', 'healthy', 'HEALTHY']))
        group = false;
    end
end
            
     