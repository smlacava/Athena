function varargout = Athena_submaking(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_submaking_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_submaking_OutputFcn, ...
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


function Athena_submaking_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3, 'Units', 'pixels');
    resizePos = get(handles.axes3, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
    cases = define_cases('');
    n = length(cases);
    subs = string(zeros(n, 1));
    for i = 1:n
        aux_s = cases(i).name;
        aux_s = split(aux_s, '.');
        subs(i) = aux_s{1};
    end
    set(handles.subs, 'String', subs);
    set(handles.subs, 'Max', n, 'Min', 0);
    

function varargout = Athena_submaking_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function back_Callback(hObject, eventdata, handles)
    close(Athena_submaking)
    

function axes3_CreateFcn(hObject, eventdata, handles)


function subs_Callback(hObject, eventdata, handles)


function subs_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function save_Callback(hObject, eventdata, handles)
    auxDir = pwd;
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    subList = get(handles.subs, 'String');
    patList = get(handles.subs, 'Value');
    n = length(subList);
    subjects = [string(subList), string(zeros(n, 1))];
    for i = 1:n
        if sum(patList == i) > 0
            subjects(i, 2) = 1;
        end
    end
    dataPath = get(handles.dataPath, 'String');
    dataPath = path_check(char_check(dataPath));
    save(strcat(dataPath, 'Subjects.mat'), 'subjects')
    cd(auxDir)
    success()



function dataPath_Callback(hObject, eventdata, handles)


function dataPath_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function search_dir_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath, 'String', d)
    end
