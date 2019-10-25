
%Possible names:
%Athena_epmean (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_epmean(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_epmean_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_epmean_OutputFcn, ...
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
function Athena_epmean_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');
    if exist('auxiliary.txt', 'file')
        auxID=fopen('auxiliary.txt','r');
        fseek(auxID, 0, 'bof');
        dataPath_line=split(fgetl(auxID),'=');
        dataPath=path_check(dataPath_line{2});
        while ~feof(auxID)
            proper=fgetl(auxID);
            if contains(proper,'measure=')
                measure=split(proper,'=');
                measure=measure{2};
            end
        end
        set(handles.dataPath_text,'String',strcat(dataPath, measure));
        fclose(auxID);
    end
        

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_epmean_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


function sub_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function sub_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function dataPath_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function dataPath_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);
    EMflag=0;
    cd(dataPath)
    if exist('auxiliary.txt', 'file')
        auxID=fopen('auxiliary.txt','a+');
    elseif exist(strcat(dataPath,'auxiliary.txt'), 'file')
        auxID=fopen(strcat(dataPath,'auxiliary.txt'),'a+');
    end
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        proper=fgetl(auxID);
        if contains(proper,'type')
            type=split(proper,'=');
            type=type{2};
        end
        if contains(proper, 'Epmean')
            EMflag=1;
        end
    end
    
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    funDir=funDir{1};
    cd(funDir);
    addpath 'Epochs Management'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    sub=get(handles.subjectsFile,'String');
    epmean_and_manage(dataPath, type, sub);
    dataPath=strcat(dataPath,'Epmean');
    dataPath=path_check(dataPath);

    PAT=strcat(dataPath,'PAT_em.mat');
    HC=strcat(dataPath,'HC_em.mat');
    if EMflag==0
        fprintf(auxID,'\nEpmean=true');
        fprintf(auxID,'\nPAT=%s', PAT);
        fprintf(auxID,'\nHC=%s', HC);
        fprintf(auxID,'\nSubjects=%s', sub);
    end
    fclose(auxID);
    success();
    dataPath=split(dataPath,'Epmean');
    dataPath=dataPath{1};
    cd(dataPath);

    
% --- Executes on button press in data_search.
function data_search_Callback(hObject, eventdata, handles)

    d=uigetdir;
    if d~=0
        set(handles.dataPath_text,'String',d)
    end



% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_epmean)
    Athena_an

% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_epmean)
    Athena_guided


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3



function subjectsFile_Callback(~, eventdata, handles)
% hObject    handle to subjectsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectsFile as text
%        str2double(get(hObject,'String')) returns contents of subjectsFile as a double


% --- Executes during object creation, after setting all properties.
function subjectsFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sub_search.
function sub_search_Callback(hObject, eventdata, handles)
% hObject    handle to sub_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [s,sp]=uigetfile;
    if s~=0
        set(handles.subjectsFile,'String',strcat(string(sp),string(s)))
    end


% --- Executes on button press in meaext.
function meaext_Callback(hObject, eventdata, handles)
% hObject    handle to meaext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(Athena_epmean)
Athena_guided


% --- Executes on button press in subMaking.
function subMaking_Callback(hObject, eventdata, handles)
% hObject    handle to subMaking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    cd(get(handles.dataPath_text,'String'))
    Athena_submaking
