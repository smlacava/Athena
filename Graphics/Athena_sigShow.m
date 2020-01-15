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
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        cases = define_cases(dataPath);
        case_name = split(cases(1).name, '.');
        case_name = case_name{1};
        set(handles.Title, 'String', strcat("    subject: ", case_name));
        [data, fs, locs] = load_data(strcat(dataPath, cases(1).name));
        if size(data, 1) > size(data, 2)
            data = data';
        end
        set(handles.locs_matrix, 'Data', locs);
        set(handles.signal_matrix, 'Data', data);
        set(handles.case_number, 'String', '1');
        if not(isempty(fs))
            set(handles.fs_text, 'String', string(fs));
            set(handles.fs_check, 'String', 'detected');
        else
            set(handles.fs_text, 'String', '1');
            fs = 1;
            set(handles.fs_check, 'String', 'not detected');
        end
        sigPlot(handles, data, fs, locs);
        
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
        [data, fs, locs] = load_data(strcat(dataPath, ...
            cases(case_number).name));
        if size(data, 1) > size(data, 2)
            data = data';
        end
        set(handles.signal_matrix, 'Data', data);
        set(handles.locs_matrix, 'Data', locs);
        set(handles.case_number, 'String', case_number);
        if isempty(fs)
            fs = str2double(get(handles.fs_text, 'String'));
            set(handles.fs_check, 'String', 'not detected');
        else
            set(handles.fs_text, 'String', string(fs));
            set(handles.fs_check, 'String', 'detected');
        end
        case_name = split(cases(case_number).name, '.');
        case_name = case_name{1};
        set(handles.Title, 'String', strcat("    subject: ", case_name));
        sigPlot(handles, data, fs, locs)
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


function fs_ClickedCallback(hObject, eventdata, handles)
    try
        fs_check = get(handles.fs_check, 'String');
        data = get(handles.signal_matrix, 'Data');
        locs = get(handles.locs_matrix, 'Data');
        fs = str2double(get(handles.fs_text, 'String'));
        if strcmp(fs, 'not detected')
            fs = 1;
        end
        axis(handles.signal);
        Lim = xlim;
        Lim = floor(Lim/fs);
        if strcmp(fs_check, 'not detected')
            fs = value_asking(fs, 'Sampling frequency', ...
                    'Insert the sampling frequency of the signal');
            while fs <= 0
                fs = value_asking(fs, 'Sampling frequency', ...
                    'Insert the sampling frequency of the signal');
            end 
            set(handles.fs_text, 'String', string(fs));
            sigPlot(handles, data, fs, locs, Lim(1), Lim(2))
        else
            problem('The sampling frequency is already setted in the file');
        end
    catch
    end


function amplitude_ClickedCallback(hObject, eventdata, handles)


function time_window_ClickedCallback(hObject, eventdata, handles)
    try
        data = get(handles.signal_matrix, 'Data');
        fs = str2double(get(handles.fs_text, 'String'));
        limit = size(data, 2)/fs;
        Lim = xlim;
        initialValue = (Lim(2)-Lim(1))/fs;
        tw = value_asking(initialValue, 'Time window', ...
            'Insert the wished time window', limit-floor(Lim(1)/fs));
        while tw <= 0
            tw = value_asking(initialValue, 'Time window', ...
                'Insert the wished time window', limit);
        end
        set(handles.time_window_value, 'String', string(tw))
        xlim([Lim(1) Lim(1)+tw*fs]);
    catch
    end
    

function Go_to_ClickedCallback(hObject, eventdata, handles)
    try
        axes(handles.signal);
        maxsize = max(size(get(handles.signal_matrix, 'Data')));
        Lim = xlim;
        fs = str2double(get(handles.fs_text, 'String'));
        window = Lim(2)-Lim(1);
        time = value_asking(floor(Lim(1)/fs), 'Go to...', ...
            'Insert the time you want to inspect', ...
            floor((maxsize-window)/fs));
        Lim = [time*fs+1, time*fs+window];
        if Lim(1) < 0
            problem('The time cannot be less than 0');
        else
            xlim(Lim);
        end
    catch
    end
    

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
    locs = get(handles.locs_matrix, 'Data');
    if not(isempty(locs))
        yticks([1:locations]*delta);
        yticklabels(locs);
    end
    xticks(0:fs:Limit);
    xticklabels(string([0:floor(Limit/fs)]));
    time_window(handles)
    
    
function sigPlot(handles, data, fs, locs, t_start, t_end)
    switch nargin
        case 4
            t_start = 0;
            t_end = str2double(get(handles.time_window_value, 'String'));
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
    if not(isempty(locs))
        yticks([1:length(locs)]*delta);
        yticklabels(locs);
    end
    xticks(0:fs:Limit);
    xticklabels(string([0:floor(Limit/fs)]));
    time_window(handles)


function TimeToSave_ClickedCallback(hObject, eventdata, handles)
    try
        data = get(handles.signal_matrix, 'Data');
        fs = str2double(get(handles.fs_text, 'String'));
        time = str2double(get(handles.TimeToSave_text, 'String'));
        time = value_asking(time, 'Time window', ...
            'Insert the length of the time window to save', ...
            max(size(data))/fs);
        set(handles.TimeToSave_text, 'String', time);
        time_window(handles);
    catch
    end
    

function tStart_text_Callback(hObject, eventdata, handles)
    time_window(handles)
    
    
function time_window(handles)
    tStart = str2double(get(handles.tStart_text, 'String'));
    fs = str2double(get(handles.fs_text, 'String'));
    time = str2double(get(handles.TimeToSave_text, 'String'));
    data = get(handles.signal_matrix, 'Data');
    
    axis(handles.signal);
    hold on;
    ymax = ylim;
    ymax = 2*ceil(ymax(2));
    window = xlim;
    
    children = get(gca, 'children');
    if size(data, 1) < length(children)
        delete(children(2))
        delete(children(1))
    end
    
    xStart = (fs*(tStart) + 1)*ones(1, 2);
    xEnd = fs*(tStart+time)*ones(1, 2);
    verticalLine = [0, ymax];
    width = ceil((window(2)-window(1))/10000);
    plot(xStart, verticalLine, 'k', 'LineWidth', width)
    plot(xEnd, verticalLine, 'r', 'LineWidth', width)
    hold off;
    

function Run_Callback(hObject, eventdata, handles)
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    subject = get(handles.Title, 'String');
    data = get(handles.signal_matrix, 'Data');
    tStart = str2double(get(handles.tStart_text, 'String'));
    time_to_save = str2double(get(handles.TimeToSave_text, 'String'));
    fs = str2double(get(handles.fs_text, 'String'));
    
    if not(exist(strcat(dataPath, 'Extracted'), 'dir'))
        mkdir(dataPath, 'Extracted');
    end
    dataPath = path_check(strcat(dataPath, 'Extracted'));
    dataPath = strcat(dataPath, subject(14:end), '.mat');
    data = data(:, tStart*fs+1:(tStart+time_to_save)*fs);
    save(dataPath, 'data');