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
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    if nargin >= 4
        dataPath='D:\Ricerca\prova';
        %dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        cases = define_cases(dataPath);
        case_name = split(cases(1).name, '.');
        case_name = case_name{1};
        set(handles.Title, 'String', strcat("    subject: ", case_name));
        [data, fs] = load_data(strcat(dataPath, cases(1).name));
        set(handles.signal_matrix, 'Data', data);
        set(handles.case_number, 'String', '1');
        if not(isempty(fs))
            set(handles.fs_text, 'String', string(fs));
        else
            set(handles.fs_text, 'String', '500');
            fs = 500;
        end
        sigPlot(handles, data, fs);
        
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
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
    set(handles.case_number, 'String', string(case_number));
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
    case_max = length(cases);
    if case_number <= case_max && case_number > 0
        [data, fs] = load_data(strcat(dataPath, cases(case_number).name));
        set(handles.signal_matrix, 'Data', data);
        set(handles.case_number, 'String', case_number);
        if isempty(fs)
            fs = str2double(get(handles.fs_text, 'String'));
        else
            set(handles.fs_text, 'String', string(fs));
        end
        case_name = split(cases(case_number).name, '.');
        case_name = case_name{1};
        set(handles.Title, 'String', strcat("    subject: ", case_name));
        sigPlot(handles, data, fs)
    elseif case_number > length(cases)
        set(handles.case_number, 'String', string(case_max));
    else
        set(handles.case_number, 'String', '1');
    end
    
    
function right_Callback(hObject, eventdata, handles)
    axes(handles.signal);
    Lim = xlim;
    fs = str2double(get(handles.fs_text, 'String'));
    Lim = Lim + fs;
    data = get(handles.signal_matrix, 'Data');
    Limit = max(size(data));
    if Lim(2) <= Limit
        xlim(Lim);
    elseif Lim(2)-fs < Limit
        xlim([Limit-Lim(2)+Lim(1)-1 Limit]);
    end
    
function left_Callback(hObject, eventdata, handles)
    axes(handles.signal);
    Lim = xlim;
    fs = str2double(get(handles.fs_text, 'String'));
    Lim = Lim - fs;
    if Lim(1) > 0
        xlim(Lim);
    elseif Lim(1)+fs > 0
        xlim([1 Lim(2)-Lim(1)+1]);
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

function zoom_Callback(hObject, eventdata, handles)
    axis(handles.signal);
    data = get(handles.signal_matrix, 'Data');
    mult = str2double(get(handles.mult, 'String'));
    set(handles.mult_text, 'String', string(mult));
    fs = str2double(get(handles.fs_text, 'String'));
    Limit = max(size(data));
    locations = size(data, 1);
    delta = max(max(abs(data)));
    Lim = xlim;
    for j = 1:locations
        plot(data(j,:)*mult+delta*(j), 'b');
        hold on
    end
    hold off
    xlim(Lim);
    ylim([0 delta*(locations+2)]);
    yticks([]);
    xticks(0:fs:Limit);
    xticklabels(string([0:floor(Limit/fs)]));
    
function sigPlot(handles, data, fs, t_start, t_end)
    switch nargin
        case 3
            t_start = 0;
            t_end = 10;
    end
    mult = str2double(get(handles.mult, 'String'));
    axis(handles.signal);
    delta = max(max(abs(data)));
    locations = size(data, 1);
    ylim([0 delta*(locations)]);
    t_end = t_end*fs;
    t_start = t_start*fs+1;
    for j = 1:locations
        plot(data(j,:)*mult+delta*(j),'b');
        hold on
    end
    hold off
    ylim([0 delta*(locations+2)]);
    xlim([t_start t_end]);
    Limit = max(size(data));
    yticks([]);
    xticks(0:fs:Limit);
    xticklabels(string([0:floor(Limit/fs)]));
