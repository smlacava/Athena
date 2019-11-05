function varargout = Athena_params_AECc(varargin)
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
    if nargin==4
        dataPath=varargin{1};
        dataPath=path_check(dataPath);
        cases=dir(fullfile(dataPath,'*.edf'));
        if not(isempty(cases))
            [data, fs]=load_data(strcat(dataPath,cases(1).name));
            if not(isempty(fs))
                set(handles.fs_text,'String', string(fs));
            end
        end
        cd(dataPath)
    end
    if nargin >= 4
        set(handles.aux_dataPath, 'String', varargin{1})
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    
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
    

function fs_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function cf_text_Callback(hObject, eventdata, handles)


function cf_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function epNum_text_Callback(hObject, eventdata, handles)


function epNum_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function epTime_text_Callback(hObject, eventdata, handles)


function epTime_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function tStart_text_Callback(hObject, eventdata, handles)


function tStart_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


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


function back_Callback(hObject, eventdata, handles)
    ddataPath = string_check(get(handles.aux_dataPath, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    close(Athena_params_AECc)
    Athena_guided(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)


function next_Callback(~, eventdata, handles)
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    close(Athena_params_AECc)
    Athena_epmean(dataPath, measure, sub, loc)
