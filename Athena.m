function varargout = Athena(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_OutputFcn, ...
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


function Athena_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1})
    addpath 'Graphics'
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

    
function varargout = Athena_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function back_Callback(hObject, eventdata, handles)
    close(Athena)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function guided_Callback(hObject, eventdata, handles)
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    close(Athena)
    Athena_guided(dataPath, sub, loc)

    
function batch_Callback(hObject, eventdata, handles)
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    close(Athena)
    Athena_batch(dataPath, measure, sub, loc)
