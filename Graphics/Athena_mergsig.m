
%Possible names:
%Athena_mergsig (Automatic Toolbox for Handling Easy Neural Analyzes)
%Apheleia (Automatic Pipeline for Handling Easy Localized Initial Analyzes)

% Multi GUI:
% int1 => save data => int2 => load data => save data2 =>...
% delete to delete partial output

function varargout = Athena_mergsig(varargin)

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_mergsig_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_mergsig_OutputFcn, ...
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
function Athena_mergsig_OpeningFcn(hObject, eventdata, handles, varargin)

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
        set(handles.dataPath_text,'String',dataPath_line(2))
        fclose(auxID);
    end
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'

    
% --- Outputs from this function are returned to the command line.
function varargout = Athena_mergsig_OutputFcn(hObject, ~, handles) 

    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function dataPath_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes on button press in checkTotal.
function checkTotal_Callback(hObject, eventdata, handles)
% hObject    handle to checkTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkTotal


% --- Executes on button press in checkGlobal.
function checkGlobal_Callback(hObject, eventdata, handles)
% hObject    handle to checkGlobal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkGlobal


% --- Executes on button press in checkAreas.
function checkAreas_Callback(hObject, eventdata, handles)
% hObject    handle to checkAreas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkAreas


% --- Executes on button press in checkAsymmetry.
function checkAsymmetry_Callback(hObject, eventdata, handles)
% hObject    handle to checkAsymmetry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkAsymmetry


% --- Executes on button press in checkPLI.
function checkPLI_Callback(hObject, eventdata, handles)
% hObject    handle to checkPLI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPLI


% --- Executes on button press in checkPLV.
function checkPLV_Callback(hObject, eventdata, handles)
% hObject    handle to checkPLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPLV

% --- Executes on button press in checkAECc.
function checkAECc_Callback(hObject, eventdata, handles)
% hObject    handle to checkAECc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in checkPSDr.
function checkPSDr_Callback(hObject, eventdata, handles)
% hObject    handle to checkPSDr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPSDr

% Hint: get(hObject,'Value') returns toggle state of checkAECc
% --- Executes on button press in checkAEC.
function checkAEC_Callback(hObject, eventdata, handles)
% hObject    handle to checkAEC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkAEC


% --- Executes on button press in checkOffset.
function checkOffset_Callback(hObject, eventdata, handles)
% hObject    handle to checkOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkOffset


% --- Executes on button press in checkExponent.
function checkExponent_Callback(hObject, eventdata, handles)
% hObject    handle to checkExponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkExponent

% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
    
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    dataPath=get(handles.dataPath_text,'String');
    dataPath=path_check(dataPath);

    anType=[];
    if get(handles.checkAsymmetry,'Value')==1
        anType=[anType "asymmetry"];
    end
    if get(handles.checkTotal,'Value')==1
        anType=[anType "total"];
    end
    if get(handles.checkGlobal,'Value')==1
        anType=[anType "global"];
    end
    if get(handles.checkAreas,'Value')==1
        anType=[anType "areas"];
    end
    
    measType=[];
    if get(handles.checkPLI,'Value')==1
        measType=[measType "PLI"];
    end
    if get(handles.checkPLV,'Value')==1
        measType=[measType "PLV"];
    end
    if get(handles.checkAEC,'Value')==1
        measType=[measType "AEC"];
    end
    if get(handles.checkAECc,'Value')==1
        measType=[measType "AECc"];
    end
    if get(handles.checkPSDr,'Value')==1
        measType=[measType "PSDr"];
    end
    if get(handles.checkOffset,'Value')==1
        measType=[measType "Offset"];
    end
    if get(handles.checkExponent,'Value')==1
        measType=[measType "Exponent"];
    end

    dataSig=[];
    Psig=[string() string() string() string()];
    SApath=strcat(dataPath, "statAn");
    SApath=path_check(SApath);
    for i=1:length(anType)
        for j=1:length(measType)
            SAfile=strcat(SApath,measType(j),'_',anType(i),'.mat');
            if exist(SAfile,'file')
                load(SAfile)
                dataSig=[dataSig, statAnResult.dataSig];
                col=size(statAnResult.Psig,2);
                if not(isempty(col))
                    if col==2
                        for r=1:size(statAnResult.Psig,1)
                            Psig=[Psig; [measType(j), anType(i), statAnResult.Psig(r,:)]];
                        end
                    else
                        for r=1:size(statAnResult.Psig,1)
                            Psig=[Psig; [measType(j), statAnResult.Psig(r,:)]];
                        end
                    end
                end
            end
        end
    end
    Psig(1,:)=[];
    
    SDfile=strcat(dataPath,"Significant_Data.csv");
    SRfile=strcat(dataPath,"Significant_Results.txt");
    if exist(SDfile,'file')
        delete(SDfile);
    end
    csvwrite(SDfile, dataSig);
    srID=fopen(SRfile,'w');
    for s=1:size(Psig,1)
        fprintf(srID,"%s %s %s %s\n", Psig(s,:));
    end
    fclose(srID);
    
    dataPath=string(dataPath);
    cd(dataPath)
    
    success();

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
    close(Athena_mergsig)
    Athena_an


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)

% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
