function varargout = Athena_epan(varargin)
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
    if nargin >= 4
        set(handles.dataPath_text, 'String', varargin{1})
    end
    if nargin >= 5
        set(handles.aux_sub, 'String', varargin{2})
    end
    if nargin == 6
        loc = varargin{3};
        if not(strcmp(loc, "Static Text"))
            set(handles.loc_text, 'String', varargin{3})
        end
    end


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


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
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

    
function back_Callback(hObject, eventdata, handles)
    dataPath = string_check(get(handles.dataPath_text, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.loc_text, 'String'));
    if strcmp(loc, "es. C:\User\Locations.mat")
        loc="Static Text";
    end
    if strcmp(dataPath, "es. C:\User\Data")
        dataPath="Static Text";
    end
    close(Athena_epan)
    Athena_an(dataPath, sub, loc)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function loc_text_Callback(hObject, eventdata, handles)


function loc_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function loc_search_Callback(hObject, eventdata, handles)
    [i,ip]=uigetfile;
    if i~=0
        set(handles.loc_text,'String',strcat(string(ip),string(i)))
    end


function Subjects_Callback(hObject, eventdata, handles)


function Subjects_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
