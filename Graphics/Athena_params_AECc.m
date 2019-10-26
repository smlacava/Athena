%Athena_params_AECc (Automatic Toolbox for Handling Easy Neural Analyzes)
function varargout = Athena_params_AECc(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_params_AECc_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_params_AECc_OutputFcn, ...
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
function Athena_params_AECc_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_params_AECc_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;

function fs_text_Callback(hObject, eventdata, handles)
    dataPath=pwd;
    dataPath=path_check(dataPath);
    cases=dir(fullfile(dataPath,'*.mat'));
    time_series=load_data(strcat(path_check(dataPath),cases(1).name));
    fs=str2double(get(handles.fs_text,'String'));
    totlen=size(time_series,2)/fs;
    if((totlen>(12*4)))
        eplen=floor((totlen-12)/3);
        set(handles.epNum_text,'String',"3");
    elseif((totlen>(12*3)))
        eplen=floor((totlen-12)/2);
        set(handles.epNum_text,'String',"2");
    elseif((totlen>(12*2)))
        eplen=12;
        set(handles.epNum_text,'String',"1");
    end
    set(handles.epTime_text,'String',string(eplen));
    

% --- Executes during object creation, after setting all properties.
function fs_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cf_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function cf_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function epNum_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function epNum_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function epTime_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function epTime_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function tStart_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function tStart_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)

    dataPath=pwd;
    dataPath=path_check(dataPath);

    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Measures'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    fs=str2double(get(handles.fs_text,'String'));
    cf=str2double(split(get(handles.cf_text,'String')," "))';
    epNum=str2double(get(handles.epNum_text,'String'));
    epTime=str2double(get(handles.epTime_text,'String'));
    tStart=str2double(get(handles.tStart_text,'String'));
     
    type="CONN";
    measure="AECo";
    connCheck=1;
    
    connectivity(fs, cf, epNum, epTime, dataPath, tStart, measure)
        
    dataPathM=strcat(dataPath,measure);
    dataPathM=path_check(dataPathM);   
    cd(dataPathM);
           
    auxID=fopen('auxiliary.txt','w');
    fprintf(auxID, 'dataPath=%s',dataPath);
    fprintf(auxID, '\nfs=%d',fs);
    fprintf(auxID, '\ncf=');
    for i = 1:length(cf)
        fprintf(auxID, '%d ',cf(i));
    end
    fprintf(auxID, '\nepNum=%d',epNum);
    fprintf(auxID, '\nepTime=%d',epTime);
    fprintf(auxID, '\ntStart=%d',tStart);
    fprintf(auxID, '\ntype=%s',type);
    fprintf(auxID, '\nmeasure=%s',measure);
    fprintf(auxID, '\nconnCheck=%d',connCheck);
    fclose(auxID);
    addpath(dataPathM);
    success();

% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_params_AECc)
    Athena


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3

% --- Executes on button press in next.
function next_Callback(~, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_params_AECc)
    Athena_epmean
