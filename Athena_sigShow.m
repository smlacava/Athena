function varargout = Athena_sigShow(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_sigShow_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_sigShow_OutputFcn, ...
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

    
function Athena_sigShow_OpeningFcn(hObject, eventdata, handles, ...
    varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.signal, 'Units', 'pixels');
    resizePos = get(handles.signal, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.signal);
    imshow(myImage);
    set(handles.signal, 'Units', 'normalized');
    if nargin >= 4
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        cases = define_cases(dataPath);
        [data, fs]=load_data(strcat(dataPath, cases(1).name));
        set(handles.signal_matrix, 'Data', data);
        set(handles.case_number, 'String', '1')
        if not(isempty(fs))
            set(handles.fs_text, 'String', string(fs));
        end
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
        set(handles.Title, 'String', strcat("     Step 1: ", measure, ...
            " extraction"))
        if strcmp(measure, "PSDr")
            set(handles.totBand, 'Visible', 'on')
            set(handles.totBand_text, 'Visible', 'on')
            set(handles.totBand_Hz, 'Visible', 'on')
        end  
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end

    
function varargout = Athena_sigShow_OutputFcn(hObject, eventdata, ...
    handles) 
    varargout{1} = handles.output;


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
    data = get(handles.signal_matrix, 'Data');
    totTime = fs*length(data);
    


function back_Callback(~, ~, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_sigShow)
    Athena(dataPath, measure, sub, loc)


function signal_CreateFcn(hObject, eventdata, handles)


function next_Callback(hObject, eventdata, handles)
    case_number = str2double(get(handles.case_number, 'String'))+2;
    set(handles.case_number, 'String', string(case_number))
    Previous_Callback(hObject, eventdata, handles)
    

function Ampliude_text_Callback(hObject, eventdata, handles)


function Ampliude_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ....
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function time_text_Callback(hObject, eventdata, handles)


function time_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
function Previous_Callback(~, ~, handles)
    dataPath = get(handles.aux_dataPath, 'String');
    dataPath = path_check(dataPath);
    case_number = str2double(get(handles.case_number, 'String'))-1;
    cases = define_cases(dataPath);
    [data, fs] = load_data(strcat(dataPath, cases(case_number).name));
    set(handles.signal_matrix, 'Data', data);
    set(handles.case_number, 'String', case_number)
    if isempty(fs)
        set(handles.fs_text, 'String', 'not defined');
        fs = 1;
    else
        set(handles.fs_text, 'String', string(fs));
    end
    locs = min(size(data));
    tw = str2double(get(handles.time_window, 'String'));
    
    for i = 1:locs
        plot(data(i, 1:tw*fs))
    end


% --------------------------------------------------------------------
function fs_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to fs_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function amplitude_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function time_window_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to time_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Go_to_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Go_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
