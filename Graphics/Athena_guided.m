%Athena_guided (Automatic Toolbox for Handling Easy Neural Analyzes)
function varargout = Athena_guided(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_guided_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_guided_OutputFcn, ...
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
function Athena_guided_OpeningFcn(hObject, eventdata, handles, varargin)

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
    cd(funDir{1});
    addpath 'Measures'
    addpath 'Auxiliary'
    addpath 'Graphics'
    if exist('fooof','file')
        set(handles.meas,'String',["relative PSD", "PLV", "PLI", "AEC", ...
            "AEC corrected", "Offset", "Exponent"]);
    else
        set(handles.meas,'String',["relative PSD", "PLV", "PLI", "AEC", ...
            "AEC corrected"]);
    end

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_guided_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function dataPath_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function fs_text_Callback(hObject, eventdata, handles)


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


function totBand_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function totBand_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
    
    meas_state=get(handles.meas,'Value');
    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);
    
    switch meas_state
        case 1
            close(Athena_guided)
            Athena_params_psd
            cd(dataPath)
        case 2
            close(Athena_guided)
            Athena_params_PLV
            cd(dataPath)
        case 3
            close(Athena_guided)
            Athena_params_PLI
            cd(dataPath)
        case 4
            close(Athena_guided)
            Athena_params_AEC
            cd(dataPath)
        case 5
            close(Athena_guided)
            Athena_params_AECc
            cd(dataPath)
        case 6
            close(Athena_guided)
            Athena_params_offset
            cd(dataPath)
        case 7
            close(Athena_guided)
            Athena_params_exponent
            cd(dataPath)
    end

    

% --- Executes on button press in data_search.
function data_search_Callback(hObject, eventdata, handles)

    d=uigetdir;
    if d~=0
        set(handles.dataPath_text,'String',d)
    end

% --- Executes during object creation, after setting all properties.
function meas_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function meas_Callback(hObject, eventdata, handles)

% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_guided)
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
    close(Athena_guided)
    Athena_epmean
