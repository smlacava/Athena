
%Possible names:
%Athena_statan (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_statan(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_statan_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_statan_OutputFcn, ...
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
function Athena_statan_OpeningFcn(hObject, eventdata, handles, varargin)

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
            if contains(proper,'measure=')
                measure=split(proper,'=');
                measure=measure{2};
            end
        end
        set(handles.dataPath_text,'String',strcat(dataPath, measure));
        fclose(auxID);
    end

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_statan_OutputFcn(hObject, ~, handles) 

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
    EMflag=0;
    LOCflag=0;
    if exist('auxiliary.txt', 'file')
        auxID=fopen('auxiliary.txt','a+');
    elseif exist(strcat(dataPath,'auxiliary.txt'), 'file')
        auxID=fopen(strcat(dataPath,'auxiliary.txt'),'a+');
    end
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        proper=fgetl(auxID);
        if contains(proper,'Epmean=')
            EMflag=1;
        elseif contains(proper,'Locations=')
            LOCflag=1;
        elseif contains(proper,'connCheck=')
            connCheck=split(proper,'=');
            connCheck=str2double(connCheck{2});
        elseif contains(proper, 'measure=')
            measure=split(proper,'=');
            measure=measure{2};
        elseif contains(proper, 'PAT=')
            PAT=split(proper,'=');
            PAT=PAT{2};
        elseif contains(proper, 'HC=')
            HC=split(proper,'=');
            HC=HC{2};
        end
    end
    
    if EMflag==0
        uiwait(msgbox('Temporal Avarage not computed','Error','custom',im));
        close(Athena_statan)
        Athena_epmean
        cd(dataPath)
    else    
        funDir=which('Athena.m');
        funDir=split(funDir,'Athena.m');
        cd(funDir{1});
        addpath 'Statistical Analysis'
        addpath 'Auxiliary'
        addpath 'Graphics'
    
        loc=get(handles.loc_text,'String');
        if LOCflag==0
            fprintf(auxID,'\nLocations=%s',loc);
        end
        fclose(auxID);
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
    
        [P, Psig, locList, data, dataSig]=mult_t_test(PAT, HC, loc, connCheck, anType, cons);
        
        bands=string();
        for i=1:size(P,1)
            bands=[bands; strcat('Band',string(i))];
        end
        bands(1,:)=[];
        bands=cellstr(bands);
        
        if length(size(data))==3
            auxData=[];
            for i=1:size(data,3)
                auxData=[auxData data(:,:,i)];
            end
            data=auxData;
            clear auxData;
        end
        
        fs1 = figure('Name','Data','NumberTitle','off');
        d = uitable(fs1,'Data',data,'Position',[20 20 525 375]);
        fs2 = figure('Name','Statistical Analysis - p-value','NumberTitle','off');
        p = uitable(fs2,'Data',P,'Position',[20 20 525 375],'RowName',bands,'ColumnName',locList);
        
        if size(Psig,1)~=0 && not(logical(sum(sum(strcmp(Psig,"")))))
            fs3 = figure('Name','Statistical Analysis - Significant Results','NumberTitle','off');
            ps = uitable(fs3,'Data',cellstr(Psig),'Position',[20 20 525 375]);
        end
        
        dataPath=char(dataPath);
        statanDir=limit_path(dataPath,measure);
        statanType=strcat(measure,'_',anType,'.mat');
        if not(exist(strcat(statanDir,'StatAn')))
            mkdir(statanDir,'statAn')
        end
        statAnResult=struct();
        statAnResult.Psig=Psig;
        statAnResult.dataSig=dataSig;
        statanDir=strcat(statanDir,'StatAn');
        statanDir=path_check(statanDir);
        save(strcat(statanDir,statanType),"statAnResult")
        
        dataPath=string(dataPath);
        cd(dataPath)
    end
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

% --- Executes during object creation, after setting all properties.
function meas_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
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
    close(Athena_statan)
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
