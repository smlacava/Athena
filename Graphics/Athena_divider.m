function varargout = Athena_divider(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_divider_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_divider_OutputFcn, ...
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

    
function Athena_divider_OpeningFcn(hObject, eventdata, handles, ...
    varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        f = waitbar(0,'Initial setup process', 'Color', '[1 1 1]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
        fchild(1).JavaPeer.setStringPainted(true)
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        cases = define_cases(dataPath);
        waitbar(0, f, 'Loading of the first signal');
        [data, fs] = load_data(strcat(dataPath, cases(1).name), 1);
        waitbar(1, f, 'Extracting available information');
        if not(isempty(fs))
            set(handles.fs_text, 'String', string(fs));
            info = strcat("Sampling frequency detected: the signal", ...
                " has a time window of ", string(length(data)/fs), " s");
            set(handles.TotTime, 'String', info);
            fs_text_Callback(hObject, eventdata, handles);
        end
        close(f)
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        if not(strcmp(varargin{4}, "Static Text"))
            set(handles.aux_loc, 'String', varargin{4})
        end
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end

    
function varargout = Athena_divider_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function fs_text_Callback(hObject, eventdata, handles)
    dataPath = get(handles.aux_dataPath, 'String');
    cases = define_cases(dataPath);
    [data, fs_old] = load_data(strcat(dataPath, cases(1).name), 1);
    fs = str2double(get(handles.fs_text, 'String'));
    TotTime = "T";
    if not(isempty(fs_old))
        if fs < fs_old
            set(handles.fs_text, 'String', string(fs));
            set(handles.fs_res, 'String', 'resampling!');
        elseif fs > fs_old
            problem("The fs cannot be higher than the fs of the data");
            set(handles.fs_text, 'String', string(fs_old));
            return;
        else
            set(handles.fs_res, 'String', '');
        end
        TotTime = "Sampling frequency detected: t";
        fs = fs_old;
    end
    TotTime = strcat(TotTime, "he signal has a time window of ", ...
        string(length(data)/fs), " s ");
    set(handles.TotTime, 'String', TotTime);

    
    
function fs_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function cf_text_Callback(hObject, eventdata, handles)
    [~, ~, totBand] = automatic_parameters(handles, "cf");
    set(handles.totBand_text, 'String', totBand)

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


function Run_Callback(hObject, eventdata, handles)
    dataPath = char_check(get(handles.aux_dataPath, 'String'));
    dataPath = path_check(dataPath);

    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Measures'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    fs = str2double(get(handles.fs_text, 'String'));
    n_time_series = str2double(get(handles.epNum_text, 'String'));
    time_window = str2double(get(handles.timeWindow_text, 'String'));

    signals_divider(dataPath, time_window, n_time_series, fs);
    success();


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_divider)
    Athena_utility(dataPath, measure, sub, loc, sub_types)


function axes3_CreateFcn(hObject, eventdata, handles)


function timeWindow_text_Callback(hObject, eventdata, handles)


function timeWindow_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
