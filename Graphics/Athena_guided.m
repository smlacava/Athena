function varargout = Athena_guided(varargin)
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


function Athena_guided_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3, 'Units', 'pixels');
    resizePos = get(handles.axes3, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Measures'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    if nargin >= 4
        aux_dataPath = varargin{1};
        if not(strcmp(aux_dataPath, 'Static Text'))
            set(handles.dataPath_text, 'String', varargin{1})
        end
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    
    if exist('fooof', 'file')
        set(handles.meas, 'String', ["relative PSD", "PLV", "PLI", ...
            "AEC", "AEC corrected", "Offset", "Exponent"]);
    else
        set(handles.meas, 'String', ["relative PSD", "PLV", "PLI", ...
            "AEC", "AEC corrected"]);
    end

    
function varargout = Athena_guided_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function fs_text_Callback(hObject, eventdata, handles)


function fs_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function cf_text_Callback(hObject, eventdata, handles)


function cf_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function epNum_text_Callback(hObject, eventdata, handles)


function epNum_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function epTime_text_Callback(hObject, eventdata, handles)


function epTime_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
            set(hObject, 'BackgroundColor', 'white');
    end


function tStart_text_Callback(hObject, eventdata, handles)


function tStart_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function totBand_text_Callback(hObject, eventdata, handles)


function totBand_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)  
    [~, ~, sub, loc] = GUI_transition(handles, 'dataPath', 'measure');
    measures = ["PSDr", "PLV", "PLI", "AEC", "AECo", "offset", "exponent"];
    dataPath = string(get(handles.dataPath_text, 'String'));
    if strcmp(dataPath, 'es. C:\User\Data')
        problem('You forgot to select the data directory')
        return
    end
    dataPath = string(path_check(dataPath));
    meas_state = get(handles.meas, 'Value');
    %params_GUI = {@Athena_params_psd, @Athena_params_PLV, ...
        %@Athena_params_PLI, @Athena_params_AEC, @Athena_params_AECc, ...
        %@Athena_params_offset, @Athena_params_exponent};
    %meas_GUI = params_GUI{meas_state};
    measure = measures(meas_state);
    close(Athena_guided)
    %meas_GUI(dataPath, measure, sub, loc);
    Athena_params(dataPath, measure, sub, loc)
    
    
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end

    
function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
    
function meas_Callback(hObject, eventdata, handles)


function back_Callback(hObject, eventdata, handles)
    [~, ~, sub, loc] = GUI_transition(handles, 'dataPath', 'measure');
    measures = ["PSDr", "PLV", "PLI", "AEC", "AECo", "offset", "exponent"];
    measure = measures(get(handles.meas, 'Value'));
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_guided)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena(dataPath, measure, sub, loc)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function next_Callback(~, eventdata, handles)
    [~, ~, sub, loc] = GUI_transition(handles, 'dataPath', 'measure');
    measures = ["PSDr", "PLV", "PLI", "AEC", "AECo", "offset", "exponent"];
    measure = measures(get(handles.meas, 'Value'));
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_guided)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena_epmean(dataPath, measure, sub, loc)