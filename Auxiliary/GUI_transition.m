%% GUI_transition(hObject, eventdata, handles, inGUI, outGUI)
% This function is used to obtain the data to exchange between two GUIs.
%
% GUI_transition(hObject, eventdata, handles)
%
% input:
%   handles are the handles of the first GUI
%   varargin is used to declare variable to not compute (they will be
%       returned as "Static Text")


function [dataPath, measure, sub, loc] = GUI_transition(handles, varargin)    
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
    
    if nargin > 1
        for i=1:nargin-1
            arg = varargin{i};
            if sum(strcmp(arg, ["dataPath", "datapath", "Datapath", ...
                "DataPath"]))
                dataPath = "Static Text";
            elseif sum(strcmp(arg, ["Meas", "Measure", "meas", ...
                    "measure"]))
                measure = "Static Text";
            elseif sum(strcmp(arg, ["sub", "Sub", "subjects", ...
                "Subjects", "subFile", "subjectsFile", "SubFile", ...
                "SubjectsFile"]))
                sub = "Static Text";
            elseif sum(strcmp(arg, ["locations", "Locations", ...
                "locFile", "LocFile", "Loc", "loc"]))
                loc = "Static Text";
            end
        end
    end 
end