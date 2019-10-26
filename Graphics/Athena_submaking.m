%Athena_submaking (Automatic Toolbox for Handling Easy Neural Analyzes)
function varargout = Athena_submaking(varargin)

% Begin initialization code
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
% End initialization code


% --- Executes just before the GUI is made visible.
function Athena_submaking_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');
    cases=dir(fullfile('*.mat'));
    n=length(cases);
    subs=string(zeros(n,1));
    for i=1:n
        aux_s=cases(i).name;
        aux_s=split(aux_s,'.mat');
        subs(i)=aux_s{1};
    end
    set(handles.subs,'String',subs);
    set(handles.subs,'Max',n,'Min',0);
    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_submaking_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3

% --- Executes on selection change in subs.
function subs_Callback(hObject, eventdata, handles)
% hObject    handle to subs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns subs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subs


% --- Executes during object creation, after setting all properties.
function subs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    auxDir=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    subList=get(handles.subs,'String');
    patList=get(handles.subs,'Value');
    n=length(subList);
    subjects=[string(subList), string(zeros(n, 1))];
    for i=1:n
        if sum(patList==i)>0
            subjects(i,2)=1;
        end
    end
    dataPath=get(handles.dataPath,'String');
    dataPath=path_check(string_check(dataPath));
    save(strcat(dataPath,'Subjects.mat'),'subjects')
    cd(auxDir)
    success()



function dataPath_Callback(hObject, eventdata, handles)
% hObject    handle to dataPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataPath as text
%        str2double(get(hObject,'String')) returns contents of dataPath as a double


% --- Executes during object creation, after setting all properties.
function dataPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in search_dir.
function search_dir_Callback(hObject, eventdata, handles)
% hObject    handle to search_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    d=uigetdir;
    if d~=0
        set(handles.dataPath,'String',d)
    end
