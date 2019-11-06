function varargout = Athena_an(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_an_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_an_OutputFcn, ...
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


function Athena_an_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');
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
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    cd(auxPath)
    

function varargout = Athena_an_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function back_Callback(hObject, eventdata, handles)
    tempav_Callback(hObject, eventdata, handles)
    
    
function axes3_CreateFcn(hObject, eventdata, handles)


function IndCorr_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    close(Athena_an)
    Athena_indcorr(dataPath, measure, sub, loc)


function MeasCorr_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    close(Athena_an)
    Athena_meascorr(dataPath, measure, sub, loc)


function StatAn_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    close(Athena_an)
    Athena_statan(dataPath, measure, sub, loc)


function clasData_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    close(Athena_an)
    Athena_mergsig(dataPath, measure, sub, loc)


function EpAn_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    close(Athena_an)
    Athena_epan(dataPath, measure, sub, loc)

    
function meaext_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    close(Athena_an)
    Athena_guided(dataPath, measure, sub, loc)

    
function tempav_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    close(Athena_an)
    Athena_epmean(dataPath, measure, sub, loc)
