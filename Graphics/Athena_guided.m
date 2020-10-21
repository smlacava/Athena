%% Athena_guided
% This interface allows to start the driven pipeline, selecting the measure
% which has to be extracted on the signals contained inside a directory.


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


%% Athena_guided_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_guided_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
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
            set(handles.aux_dataPath, 'String', varargin{1})
        end
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    if exist('fooof', 'file')
        set(handles.meas, 'String', Athena_measures_list());
    else
        set(handles.meas, 'String', Athena_measures_list(0, 1));
    end
    
    Athena_history_update({}, 1);
    
  
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


%% Run_Callback
% This function switches to the Measure Parameters Selection interface.
function Run_Callback(hObject, eventdata, handles)  
    [~, ~, sub, loc, sub_types] = GUI_transition(handles, 'dataPath', ...
        'measure');
    measures = get(handles.meas, 'String');
    dataPath = string(get(handles.dataPath_text, 'String'));
    
    if strcmp(dataPath, 'es. C:\User\Data')
        problem('You forgot to select the data directory')
        return
    end
    if not(exist(dataPath, 'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    
    dataPath = string(path_check(dataPath));
    meas_state = get(handles.meas, 'Value');
    measure = measures{meas_state};
    close(Athena_guided)
    Athena_params(dataPath, measure, sub, loc, sub_types)
    

%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end
    dataPath_text_Callback(hObject, eventdata, handles)

    
function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
    
function meas_Callback(hObject, eventdata, handles)


%% back_Callback
% This function switches to the first interface of the toolbox.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [~, ~, sub, loc, sub_types] = GUI_transition(handles, 'dataPath', ...
        'measure');
    measures = Athena_measures_list();
    measure = measures(get(handles.meas, 'Value'));
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_guided)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


%% next_Callback
% This function switches to the Temporal and Spatial Management interface.
function next_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    if strcmp(get(handles.dataPath_text, 'String'), ...
            get(handles.aux_dataPath, 'String')) == 0
        if strcmpi(get(handles.aux_dataPath, 'String'), 'Static Text') == 0
            set(handles.aux_loc, 'String', 'Static Text')
            set(handles.aux_sub, 'String', 'Static Text')
        end
    end
    [~, ~, sub, loc, sub_types] = GUI_transition(handles, 'dataPath', ...
        'measure');
    measures = Athena_measures_list();
    measure = measures(get(handles.meas, 'Value'));
    dataPath = string(get(handles.dataPath_text, 'String'));
    if not(exist(dataPath, 'dir'))
        msg = 'Continue without selecting a valid directory?';
        title = 'Directory not found';
        answer = user_decision(msg, title);
        if strcmpi(answer, 'no')
            return;
        end
    end
    close(Athena_guided)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena_epmean(dataPath, measure, sub, loc, sub_types)
