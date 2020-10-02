function varargout = Athena_batch(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_batch_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_batch_OutputFcn, ...
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

    
function Athena_batch_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    addpath 'Auxiliary'
    if nargin >= 4
        set(handles.aux_dataPath, 'String', varargin{1})
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end
        

function varargout = Athena_batch_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function sub_text_Callback(hObject, eventdata, handles)


function sub_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function dataFile_text_Callback(hObject, eventdata, handles)


function dataFile_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    addpath 'Batch'
    addpath 'Correlations'
    addpath 'Epochs Management'
    addpath 'Epochs Analysis'
    addpath 'Classification'
    addpath 'Measures'
    addpath 'Statistical Analysis'
    
    
	dataFile = char_check(get(handles.dataFile_text, 'String'));
    if not(exist(dataFile, 'file'))
        problem(strcat("File ", dataFile, " not found"))
        return
    else
        batch_study(dataFile);
    end
    
    
function data_search_Callback(hObject, ~, handles)
    [i, ip] = uigetfile({'*.*'});
    if i ~= 0
        set(handles.dataFile_text, 'String', strcat(string(ip), string(i)))
    end


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_batch)
    Athena(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)
