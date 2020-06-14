%% GUI_transition(hObject, eventdata, handles, inGUI, outGUI)
% This function is used to obtain the data to exchange between two GUIs.
%
% [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles, ...
%         varargin)
%
% Input:
%   handles are the handles of the first GUI
%   varargin is used to declare variable to not compute (they will be
%       returned as "Static Text")
%
% Output:
%   dataPath is the data directory
%   measure is the measure name
%   sub is the file which contains the list of the subjects
%   loc is the file which contains the list of the locations
%   sub_types is the list of subjects' types


function [dataPath, measure, sub, loc, sub_types] = ...
    GUI_transition(handles, varargin)    
    funDir = which('Athena.m');
    funDir = split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Graphics'
    
    fields = fieldnames(handles);
    if sum(strcmp(fields,'aux_dataPath'))
        dataPath = string(get(handles.aux_dataPath, 'String'));
    end
    if sum(strcmp(fields,'aux_measure'))
        measure = string(get(handles.aux_measure, 'String'));
    end
    if sum(strcmp(fields,'aux_sub'))
        sub = string(get(handles.aux_sub, 'String'));
    end
    if sum(strcmp(fields,'aux_loc'))
        loc = string(get(handles.aux_loc, 'String'));
    end
    if sum(strcmp(fields,'sub_types'))
        sub_types = get(handles.sub_types, 'Data');
        try
            if isempty(sub_types{1})
                sub_types = {};
            end
        catch
        end
    end
    
    if nargin > 1
        for i=1:nargin-1
            arg = varargin{i};
            if strcmpi(arg, "dataPath")
                dataPath = "Static Text";
            elseif sum(strcmpi(arg, ["Meas", "Measure"]))
                measure = "Static Text";
            elseif sum(strcmpi(arg, ["sub", "subjects", "subFile", ...
                    "subjectsFile"]))
                sub = "Static Text";
            elseif sum(strcmpi(arg, ["locations", "LocFile", "Loc"]))
                loc = "Static Text";
            elseif sum(strcmpi(arg, ["sub_types"]))
                sub_types = "Static Text";
            end
        end
    end 
end