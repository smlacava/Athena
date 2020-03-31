function varargout = Athena_mergsig(varargin)
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

    
function Athena_mergsig_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3, 'Units', 'pixels');
    resizePos = get(handles.axes3, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
        if not(strcmp(path, 'Static Text'))
            set(handles.dataPath_text, 'String', path)
        end
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        loc = varargin{4};
        if not(strcmp(loc, 'Static Text'))
            set(handles.aux_loc, 'String', loc)
        end
    end

    
function varargout = Athena_mergsig_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
        set(handles.aux_dataPath, 'String', ...
            get(handles.dataPath_text, 'String'))
        

function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function checkTotal_Callback(hObject, eventdata, handles)


function checkGlobal_Callback(hObject, eventdata, handles)


function checkAreas_Callback(hObject, eventdata, handles)


function checkAsymmetry_Callback(hObject, eventdata, handles)


function checkPLI_Callback(hObject, eventdata, handles)


function checkPLV_Callback(hObject, eventdata, handles)


function checkAECc_Callback(hObject, eventdata, handles)


function checkPSDr_Callback(hObject, eventdata, handles)


function checkAEC_Callback(hObject, eventdata, handles)


function checkOffset_Callback(hObject, eventdata, handles)


function checkExponent_Callback(hObject, eventdata, handles)


function Run_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    if not(exist(dataPath, 'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    
    dataType = 'Significant';
    if get(handles.allData, 'Value') == 1
        dataType = 'All';
    end

    anType = [];
    if get(handles.checkAsymmetry, 'Value') == 1
        anType = [anType "asymmetry"];
    end
    if get(handles.checkTotal, 'Value') == 1
        anType = [anType "total"];
    end
    if get(handles.checkGlobal, 'Value') == 1
        anType = [anType "global"];
    end
    if get(handles.checkAreas, 'Value') == 1
        anType = [anType "areas"];
    end
    
    measType=[];
    if get(handles.checkPLI, 'Value') == 1
        measType=[measType "PLI"];
    end
    if get(handles.checkPLV, 'Value') == 1
        measType = [measType "PLV"];
    end
    if get(handles.checkAEC, 'Value') == 1
        measType = [measType "AEC"];
    end
    if get(handles.checkAECc, 'Value') == 1
        measType = [measType "AECo"];
    end
    if get(handles.checkPSDr, 'Value') == 1
        measType = [measType "PSDr"];
    end
    if get(handles.checkOffset, 'Value') == 1
        measType = [measType "Offset"];
    end
    if get(handles.checkExponent, 'Value') == 1
        measType = [measType "Exponent"];
    end

    classification_data_settings(dataPath, anType, measType, dataType);
    
    success();


function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        set(handles.aux_dataPath, 'String', d)
        auxPath = pwd;
        dataPath = get(handles.dataPath_text, 'String');
        dataPath = path_check(dataPath);
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
                if contains(proper, 'Subjects=')
                    subsFile = split(proper, '=');
                    subsFile = subsFile{2};
                    set(handles.aux_sub, 'String', subsFile);
                end
                if contains(proper, 'Locations=')
                    locations = split(proper, '=');
                    locations = locations{2};
                    set(handles.aux_loc, 'String', locations)
                end
            end
            fclose(auxID);     
        end
        cd(auxPath)
    end


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath="Static Text";
    end
    close(Athena_mergsig)
    Athena_an(dataPath, measure, sub, loc)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function checkbox5_Callback(hObject, eventdata, handles)


function checkbox7_Callback(hObject, eventdata, handles)


function Classification_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_mergsig)
    Athena_classification(dataPath, measure, sub, loc)


function allData_Callback(hObject, eventdata, handles)


function sigData_Callback(hObject, eventdata, handles)


function checkbox26_Callback(hObject, eventdata, handles)