
%Possible names:
%Athena_meascorr (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_meascorr(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_meascorr_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_meascorr_OutputFcn, ...
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
function Athena_meascorr_OpeningFcn(hObject, eventdata, handles, varargin)

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
        dataPath=split(fgetl(auxID),'=')';
        set(handles.dataPath_text,'String',dataPath{2})
        while ~feof(auxID)
            proper=fgetl(auxID);
            if contains(proper,'Locations=')
                locations=split(proper,'=');
                locations=locations{2};
                set(handles.loc_text,'String',locations)
            end
        end
        fclose(auxID);
    end

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_meascorr_OutputFcn(hObject, eventdata, handles) 

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
            if contains(proper,'Locations=')
                locations=split(proper,'=');
                locations=locations{2};
                set(handles.loc_text,'String',locations)
            end
        end
        fclose(auxID);     
    end
    cd(auxPath)


% --- Executes during object creation, after setting all properties.
function dataPath_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)

    im=imread('untitled3.png');
    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);
    cd(dataPath)
    
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Measures Correlation'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    pat_state=get(handles.PAT,'Value');
    hc_state=get(handles.HC,'Value');
    loc=get(handles.loc_text,'String');
    minCons_state=get(handles.minCons,'Value');
    maxCons_state=get(handles.maxCons,'Value');
    
    if get(handles.asy_button,'Value')==1
        anType="asymmetry";
    elseif get(handles.tot_button,'Value')==1
        anType="total";
    elseif get(handles.glob_button,'Value')==1
        anType="global";
    else
        anType="areas";
    end
    
    if minCons_state==1
        cons=0;
    else
        cons=1;
    end
        
    meas_state=[get(handles.meas1,'Value') get(handles.meas2,'Value')];     
    type=["" ""];
    for i=1:length(type)
        connCheck=0;
        switch meas_state(i)
            case 1
                type(i)="PSDr";
            case 2
                type(i)="PLV";
                connCheck=1;
            case 3
                type(i)="PLI";
                connCheck=1;
            case 4
                type(i)="AEC";
                connCheck=1;
            case 5
                type(i)="AECo";
                connCheck=1;
        end
           
        dataPathM=strcat(dataPath,type(i));
        dataPathM=path_check(dataPathM);
        LOCflag=0;
        cd(dataPathM);
        if exist('auxiliary.txt', 'file')
            auxID=fopen('auxiliary.txt','a+');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper=fgetl(auxID);
                if contains(proper,'Locations=')
                    LOCflag=1;
                end
            end
        end
        if LOCflag==0
            fprintf(auxID,'\nLocations=%s',loc);
        end
        fclose(auxID);
        
        dataPathM=strcat(dataPathM,'Epmean');    
        if not(exist(dataPathM,'dir'))
            break
            uiwait(msgbox('Temporal Avarage not computed','Error','custom',im));
            close(Athena_meascorr)
            Athena_epmean
            cd(dataPath)
        else
            dataPathM=path_check(dataPathM);
            if pat_state==1
                dataPathM=strcat(dataPathM,'PAT_em.mat');
            elseif hc_state==1
                dataPathM=strcat(dataPathM,'HC_em.mat');
            end
            [d, locList]=measures_manager(dataPathM, loc,  connCheck, anType);
            if i==1
                data1=d;
            else
                data2=d;
            end
        end
    end
    
    type1=type(1);
    type2=type(2);
    nBands=size(data1,2);
    for i=1:length(locList) 
        for j=1:nBands
            correlation(data1(:,j,i), data2(:,j,i), ...
                strcat("Band", string(j), " ", locList(i)), type1, type2)
        end
    end
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
                if contains(proper,'Locations=')
                    locations=split(proper,'=');
                    locations=locations{2};
                    set(handles.loc_text,'String',locations)
                end
            end
            fclose(auxID);     
        end
        cd(auxPath)
    end


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(Athena_meascorr)
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



% --- Executes on selection change in meas1.
function meas1_Callback(hObject, eventdata, handles)
% hObject    handle to meas1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns meas1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from meas1


% --- Executes during object creation, after setting all properties.
function meas1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meas1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in meas2.
function meas2_Callback(hObject, eventdata, handles)
% hObject    handle to meas2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns meas2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from meas2


% --- Executes during object creation, after setting all properties.
function meas2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meas2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
