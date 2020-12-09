%% Athena_commonSubjects
% This interface is used to extract the files related to the common
% subjects between two directories.

function varargout = Athena_commonSubjects(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @Athena_commonSubjects_OpeningFcn, ...
        'gui_OutputFcn',  @Athena_commonSubjects_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end

%% Athena_divierPath_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_commonSubjects_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    if nargin >= 4
        aux_dataPath = varargin{1};
        if not(strcmp(aux_dataPath, 'Static Text'))
            set(handles.dataPath_text, 'String', varargin{1})
        end
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end

    
function varargout = Athena_commonSubjects_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath2_text_Callback(hObject, eventdata, handles)


function dataPath2_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

 
%% data_search_Callback
% This function is used to search the first data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end

    
%% data_search2_Callback
% This function is used to search the second data directory through the
% file explorer.
function data_search2_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath2_text, 'String', d)
    end


%% back_Callback
% This function switches to the Utility list interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [~, measure, sub, loc, sub_types] = GUI_transition(handles, ...
        'dataPath', 'measure');
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_commonSubjects)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena_utility(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


%% Run_Callback
% This function extracts the common subjects from two different
% directories.
function Run_Callback(hObject, eventdata, handles)
    subjects_management(get(handles.dataPath_text, 'String'), ...
        get(handles.dataPath2_text, 'String'));
    success()

    
%% dataPath_KeyPressFcn
% This function is used to use a keyboard command on the first data
% directory edit text.
function dataPath_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'downarrow') || ...
            strcmpi(eventdata.Key, 'uparrow')
        uicontrol(handles.dataPath2_text);
    end
    

%% dataPath2_KeyPressFcn
% This function is used to use a keyboard command on the second data
% directory edit text.
function dataPath2_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'downarrow') || ...
            strcmpi(eventdata.Key, 'uparrow')
        uicontrol(handles.dataPath_text);
    end