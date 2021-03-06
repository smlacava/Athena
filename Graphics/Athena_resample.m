%% Athena_resample
% This interface allows to resample all the signals, contained inside the
% same data directory, to the same sampling frequency.


function varargout = Athena_resample(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @Athena_resample_OpeningFcn, ...
        'gui_OutputFcn',  @Athena_resample_OutputFcn, ...
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


%% Athena_resample_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_resample_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    if nargin >= 4
        aux_dataPath = varargin{1};
        if not(strcmp(aux_dataPath, 'Static Text'))
            set(handles.dataPath_text, 'String', varargin{1})
        end
        if exist(varargin{1}, 'dir')
            cases = define_cases(varargin{1});
            [~, fs, ~] = load_data(strcat(path_check(varargin{1}), ...
                cases(1).name));
            if not(isempty(fs))
                set(handles.fs_text, 'String', string(fs))
            end
        end
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
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

    
function varargout = Athena_resample_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% dataPath_text_Callback
% This function is called when the dataPath is modified, in order to
% refresh the interface, and to set the sampling frequency of the first
% time series as the corresponding parameter.
function dataPath_text_Callback(hObject, eventdata, handles)
    dataPath = path_check(get(handles.dataPath_text, 'String'));
    if exist(dataPath, 'dir')
    	cases = define_cases(dataPath);
        [~, fs, ~] = load_data(strcat(dataPath, cases(1).name));
        if not(isempty(fs))
            set(handles.fs_text, 'String', string(fs))
        end
    end

    
function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
    aux_path = get(handles.dataPath_text, 'String');
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end
    if d ~= 0 && strcmp(aux_path, d) == 0
        dataPath_text_Callback(hObject, eventdata, handles)
    end


%% back_Callback
% This function switches to the Utilities list interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [~, measure, sub, loc, sub_types] = GUI_transition(handles, ...
        'dataPath', 'measure');
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_resample)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena_utility(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function fs_text_Callback(hObject, eventdata, handles)


function fs_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%% RUN_Callback
% This function is used when the Run button is pushed, and it resamples all
% the signals and saves them in a subdirectory of the chosen directory.
function RUN_Callback(hObject, eventdata, handles)
    dataset_resample(get(handles.dataPath_text, 'String'), ...
        str2double(get(handles.fs_text, 'String')))
    success()

    
%% fs_KeyPressFcn
% This function is used to use a keyboard command on the sampling frequency
% edit text.
function fs_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'downarrow') || ...
            strcmpi(eventdata.Key, 'uparrow')
        uicontrol(handles.dataPath_text);
    end
    
    
%% dataPath_KeyPressFcn
% This function is used to use a keyboard command on the data directory
% edit text.
function dataPath_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'downarrow') || ...
            strcmpi(eventdata.Key, 'uparrow')
        uicontrol(handles.fs_text);
    end
