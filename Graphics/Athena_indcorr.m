
%Possible names:
%Athena_indcorr (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_indcorr(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_indcorr_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_indcorr_OutputFcn, ...
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
function Athena_indcorr_OpeningFcn(hObject, eventdata, handles, varargin)

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
        fclose(auxID);
        set(handles.dataPath_text,'String',strcat(dataPath, measure));
    end

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_indcorr_OutputFcn(hObject, eventdata, handles) 

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
            elseif contains(proper,'Index=')
                ind=split(proper,'=');
                ind=ind{2};
                set(handles.ind_text,'String',ind)
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
    if iscell(dataPath)
        dataPath=dataPath{1};
    end
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
        elseif contains(proper, 'Subjects=')
            sub=split(proper,'=');
            sub=sub{2};
        end
    end
    
    if EMflag==0
        uiwait(msgbox('Epochs Avarage not computed','Error','custom',im));
        close(Athena_indcorr)
        Athena_epmean
        cd(dataPath)
    else   
        funDir=which('Athena.m');
        funDir=split(funDir,'Athena.m');
        cd(funDir{1});
        addpath 'Index Correlation'
        addpath 'Auxiliary'
        addpath 'Graphics'
    
        Ind=get(handles.ind_text,'String');
        pat_corr_state=get(handles.PAT,'Value');
        hc_corr_state=get(handles.HC,'Value');
        loc=get(handles.loc_text,'String');
        if LOCflag==0
            fprintf(auxID,'\nLocations=%s',loc);
        end
        fclose(auxID);
        minCons_state=get(handles.minCons,'Value');
        maxCons_state=get(handles.maxCons,'Value');
        
        Subjects=load_data(sub);
    
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
    
        if pat_corr_state==1
            sub=Subjects(Subjects(:,end)==1,1);
            [RHO, P, RHOsig, locList]=index_correlation(PAT, Ind, loc, connCheck, anType, cons, measure, sub);
        elseif hc_corr_state==1
            sub=Subjects(Subjects(:,end)==0,1);
            [RHO, P, RHOsig, locList]=index_correlation(HC, Ind, loc, connCheck, anType, cons, measure, sub);
        end
        
        bands=string();
        for i=1:size(RHO,1)
            bands=[bands; strcat('Band',string(i))];
        end
        bands(1,:)=[];
        bands=cellstr(bands);
        
        fc1 = figure('Name','Correlations - RHO','NumberTitle','off');
        rho = uitable(fc1,'Data',RHO,'Position',[20 20 525 375],'RowName',bands,'ColumnName',locList);
        fc2 = figure('Name','Correlations - p-value','NumberTitle','off');
        pcorr = uitable(fc2,'Data',P,'Position',[20 20 525 375],'RowName',bands,'ColumnName',locList);
        if size(RHOsig,1)~=0 && not(logical(sum(sum(strcmp(RHOsig,"")))))
            fc3 = figure('Name','Correlations - Significant Results','NumberTitle','off');
            rhos = uitable(fc3,'Data',cellstr(RHOsig),'Position',[20 20 525 375]);
        end
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
                elseif contains(proper,'Index=')
                    ind=split(proper,'=');
                    ind=ind{2};
                    set(handles.ind_text,'String',ind)
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
    close(Athena_indcorr)
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



function ind_text_Callback(hObject, eventdata, handles)
% hObject    handle to ind_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ind_text as text
%        str2double(get(hObject,'String')) returns contents of ind_text as a double


% --- Executes during object creation, after setting all properties.
function ind_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ind_search.
function ind_search_Callback(hObject, eventdata, handles)
% hObject    handle to ind_search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [i,ip]=uigetfile;
    if i~=0
        set(handles.ind_text,'String',strcat(string(ip),string(i)))
    end
