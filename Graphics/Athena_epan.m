
%Possible names:
%Athena_epan (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_epan(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_epan_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_epan_OutputFcn, ...
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
function Athena_epan_OpeningFcn(hObject, eventdata, handles, varargin)

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
        dataPath_line=split(fgetl(auxID),'=')';
        dataPath=path_check(dataPath_line{2});
        while ~feof(auxID)
            proper=fgetl(auxID);
            if contains(proper,'Locations=')
                locations=split(proper,'=');
                locations=locations{2};
                set(handles.loc_text,'String',locations)
            end
            if contains(proper,'Subjects=')
                subsFile=split(proper,'=');
                subsFile=subsFile{2};
                subs=load_data(subsFile);
                subs=string(subs(:,1))';
            end
            if contains(proper,'measure=')
                measure=split(proper,'=');
                measure=measure{2};
            end
        end
        fclose(auxID);   
        set(handles.dataPath_text,'String',strcat(dataPath, measure));
        set(handles.Subjects,'String',subs);
    end

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_epan_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);
    cd(dataPath)
    if exist('auxiliary.txt', 'file')
        auxID=fopen('auxiliary.txt','r');
        fseek(auxID, 0, 'bof');
        while ~feof(auxID)
            proper=fgetl(auxID);
            if contains(proper,'Subjects=')
                subsFile=split(proper,'=');
                subsFile=subsFile{2};
                subs=load_data(subsFile);
                subs=string(subs(:,1))';
            end
            if contains(proper,'Locations=')
                locations=split(proper,'=');
                locations=locations{2};
                set(handles.loc_text,'String',locations)
            end
        end
        fclose(auxID);     
        set(handles.Subjects,'String',subs);
    end
    cd(auxPath)


% --- Executes during object creation, after setting all properties.
function dataPath_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)

    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);
    cd(dataPath)
    
    if exist('auxiliary.txt', 'file')
        auxID=fopen('auxiliary.txt','r');
        fseek(auxID, 0, 'bof');
    end
    while ~feof(auxID)
        proper=fgetl(auxID);
        if contains(proper,'epNum=')
            epochs=split(proper,'=');
            epochs=str2double(epochs{2});
        end
        if contains(proper,'measure=')
            measure=split(proper,'=');
            measure=measure{2};
        end
        if contains(proper,'cf=')
            bands=split(proper,'=');
            bands=split(bands{2},' ');
            bands=length(bands)-2;
        end
    end
    fclose(auxID);
    
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'

    loc=get(handles.loc_text,'String');
    subList=get(handles.Subjects,'String');
    subName=subList(get(handles.Subjects,'Value'));
    
    if get(handles.asy_button,'Value')==1
        anType="asymmetry";
    elseif get(handles.tot_button,'Value')==1
        anType="total";
    elseif get(handles.glob_button,'Value')==1
        anType="global";
    else
        anType="areas";
    end
    
    
    epochs_analysis(dataPath, subName, anType, measure, epochs, bands, loc)
           
    cd(dataPath)
       
% --- Executes on button press in data_search.
function data_search_Callback(hObject, eventdata, handles)

    d=uigetdir;
    if d~=0
        set(handles.dataPath_text,'String',d)
        auxPath=pwd;
        dataPath=get(handles.dataPath_text,'String');
        dataPath=path_check(dataPath);
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID=fopen('auxiliary.txt','r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper=fgetl(auxID);
                if contains(proper,'Subjects=')
                    subsFile=split(proper,'=');
                    subsFile=subsFile{2};
                    subs=load_data(subsFile);
                    subs=string(subs(:,1))';
                end
                if contains(proper,'Locations=')
                    locations=split(proper,'=');
                    locations=locations{2};
                    set(handles.loc_text,'String',locations)
                end
            end
            fclose(auxID);     
            set(handles.Subjects,'String',subs);
        end
        cd(auxPath)
    end


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);
    if exist(dataPath,'dir')
        cd(dataPath)
    end
    close(Athena_epan)
    Athena_an


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3



function loc_text_Callback(hObject, eventdata, handles)
% hObject    handle to loc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loc_text as text
%        str2double(get(hObject,'String')) returns contents of loc_text as a double


% --- Executes during object creation, after setting all properties.
function loc_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loc_search.
function loc_search_Callback(hObject, eventdata, handles)
% hObject    handle to loc_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [i,ip]=uigetfile;
    if i~=0
        set(handles.loc_text,'String',strcat(string(ip),string(i)))
    end


% --- Executes on selection change in Subjects.
function Subjects_Callback(hObject, eventdata, handles)
% hObject    handle to Subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Subjects contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Subjects


% --- Executes during object creation, after setting all properties.
function Subjects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Subjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
