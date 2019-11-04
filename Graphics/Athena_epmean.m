function varargout = Athena_epmean(varargin)
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
    if nargin >= 4
        aux_dataPath = varargin{1};
        if not(strcmp(aux_dataPath, 'Static Text'))
            dataPath=path_check(aux_dataPath);
            cd(dataPath)
            set(handles.dataPath_text,'String',dataPath)
        end
    end
    if nargin >= 5
        aux_sub = varargin{2};
        if not(strcmp(aux_sub, 'Static Text'))
            set(handles.subjectsFile, 'String', aux_sub)
        end
    end
    if nargin == 6
        set(handles.aux_loc, 'String', varargin{3})
    end
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
        

function varargout = Athena_epmean_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function sub_text_Callback(hObject, eventdata, handles)


function sub_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


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

    
function data_search_Callback(hObject, eventdata, handles)
    d=uigetdir;
    if d~=0
        set(handles.dataPath_text,'String',d)
    end


function next_Callback(hObject, eventdata, handles)
    dataPath = string_check(get(handles.dataPath_text, 'String'));
    sub = string_check(get(handles.subjectsFile, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));   
    close(Athena_epmean)
    Athena_an(dataPath, sub, loc)


function back_Callback(hObject, eventdata, handles)
    meaext_Callback(hObject, eventdata, handles)


function axes3_CreateFcn(hObject, eventdata, handles)


function subjectsFile_Callback(~, eventdata, handles)


function subjectsFile_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function sub_search_Callback(hObject, eventdata, handles)
    [s,sp]=uigetfile;
    if s~=0
        set(handles.subjectsFile,'String',strcat(string(sp),string(s)))
    end


function meaext_Callback(hObject, eventdata, handles)
    sub = string(get(handles.subjectsFile, 'String'));
    loc = string(get(handles.aux_loc, 'String'));
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    dataPath = char(path_check(string_check(get(handles.dataPath_text, ...
        'String'))));
    dataAux = split(dataPath, dataPath(end));
    if not(strcmp(dataAux(1), 'S'))
        dataPath = string(limit_path(dataPath, dataAux(end-1)));
    end
    if strcmp('es. C:\User\Sub.mat', sub)
        sub = "Static Text";
    end
    close(Athena_epmean)
    Athena_guided(string(dataPath), sub, loc)


function subMaking_Callback(hObject, eventdata, handles)
    cd(get(handles.dataPath_text,'String'))
    Athena_submaking
