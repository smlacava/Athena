function varargout = Athena_sigPath(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @Athena_sigPath_OpeningFcn, ...
        'gui_OutputFcn',  @Athena_sigPath_OutputFcn, ...
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


function Athena_sigPath_OpeningFcn(hObject, eventdata, handles, varargin)
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
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end

    
function varargout = Athena_sigPath_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

    
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end



function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [~, measure, sub, loc] = GUI_transition(handles, 'dataPath', 'measure');
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_sigPath)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena(dataPath, measure, sub, loc)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function next_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [~, measure, sub, loc] = GUI_transition(handles, 'dataPath', 'measure');
    dataPath = string(get(handles.dataPath_text, 'String'));
    if exist(dataPath, 'dir')
        close(Athena_sigPath)
        if strcmp('es. C:\User\Data', dataPath)
            dataPath = "Static Text";
        end
        Athena_sigShow(dataPath, measure, sub, loc)
    else
        problem('Data directory not found.')
    end
