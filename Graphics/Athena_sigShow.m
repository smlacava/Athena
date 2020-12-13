%% Athena_sigShow
% This interface allows to show the signals, to filter it, to take a 
% picture of its shown time window, to save a piece of it, rereference it, 
% and explore it manually or automatically.


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


%% Athena_sigShow_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_sigShow_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    try 
        net_name = strcat(path_check(limit_path(mfilename('fullpath'), ...
            'Graphics')), 'Classification', filesep, 'TrainedDNN', ...
            filesep, 'commandNet.mat');
        load(fullfile_check(net_name));
        handles.net = trainedNet;
    catch
    end
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.logo, 'CData', Im)
    %set(handles.signal, 'Units', 'normalized');
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    if nargin >= 4
        f = waitbar(0, 'Initialization', 'Color', '[1 1 1]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(...
            fchild(1).JavaPeer.getBackground.BLUE)
            fchild(1).JavaPeer.setStringPainted(true)
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        cases = define_cases(dataPath);
        case_name = split(cases(1).name, '.');
        case_name = case_name{1};
        set(handles.Title, 'String', strcat("    subject: ", case_name));
        [data, fs, locs, chanlocs] = load_data(strcat(dataPath, ...
            cases(1).name));
        if size(data, 1) > size(data, 2)
            data = data';
        end
        locs_ind = location_index(locs, data);
        try
            set(handles.chanlocs, 'Data', ...
                double([chanlocs.X; chanlocs.Y; chanlocs.Z]'))
        catch
            set(handles.chanlocs, 'Data', []);
        end
        set(handles.locs_ind, 'Data', locs_ind);
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
            set(handles.fs_text, 'String', string(value_asking(1, ...
                'Sampling frequency not found', ...
                'Insert the sampling frequency of this time series')));
            
        end
        tw = str2double(get(handles.time_window_value, 'String'));
        set(handles.time_window_value, 'String', ...
            string(min(tw, length(data))))
        waitbar(0.5, f)
        close(f)
        sigPlot(handles, data, fs, locs);
        set(handles.logo, 'Visible', 'off')
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
    
    
function varargout = Athena_sigShow_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


%% back_Callback
% This function switches to the initial interface of the toolbox.
function back_Callback(~, ~, handles)
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_sigShow)
    Athena(dataPath, measure, sub, loc, sub_types)


function signal_CreateFcn(~, ~, ~)


%% next_Callback
% This function switches to the following time series.
function next_Callback(hObject, eventdata, handles)
    case_number = str2double(get(handles.case_number, 'String'))+2;
    set(handles.case_number, 'String', string(case_number));
    Previous_Callback(hObject, eventdata, handles)
    

function Ampliude_text_Callback(~, ~, ~)


function Ampliude_text_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), ....
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function time_text_Callback(~, ~, ~)


function time_text_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%% Previous_Callback
% This function switches to the previous time series.
function Previous_Callback(hObject, ~, handles)    
    dataPath = get(handles.aux_dataPath, 'String');
    dataPath = path_check(dataPath);
    case_number = str2double(get(handles.case_number, 'String'))-1;
    cases = define_cases(dataPath);
    case_max = length(cases);
    if case_number <= case_max && case_number > 0
        f = waitbar(0, 'Data loading', 'Color', '[1 1 1]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(...
            fchild(1).JavaPeer.getBackground.BLUE)
        fchild(1).JavaPeer.setStringPainted(true)
        [data, fs, locs, chanlocs] = load_data(strcat(dataPath, ...
            cases(case_number).name));
        try
            set(handles.chanlocs, 'Data', ...
                double([chanlocs.X; chanlocs.Y; chanlocs.Z]'))
        catch
            set(handles.chanlocs, 'Data', []);
        end
        waitbar(0.5, f, 'Processing your data')
        hold off
        if size(data, 1) > size(data, 2)
            data = data';
        end
        if isempty(locs)
            locs = get(handles.locs_matrix, 'Data');
        end
        locs_ind = location_index(locs, data);
        tw = str2double(get(handles.time_window_value, 'String'));
        set(handles.time_window_value, 'String', ...
            string(min(tw, length(data))))
        set(handles.signal_matrix, 'Data', data);
        set(handles.locs_matrix, 'Data', locs);
        set(handles.locs_ind, 'Data', locs_ind);
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
        reset_filtered(handles);
        close(f)
        sigPlot(handles, data, fs, locs)
    elseif case_number > length(cases)
        set(handles.case_number, 'String', string(case_max));
    else
        set(handles.case_number, 'String', '1');
    end
    

%% right_Callback
% This function switches the shown time window a second forward.
function right_Callback(~, ~, handles)
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
    
    
%% left_Callback
% This function switches the shown time window a second backward.
function left_Callback(~, ~, handles)
    axes(handles.signal);
    Lim = xlim;
    fs = str2double(get(handles.fs_text, 'String'));
    Lim = Lim - fs;
    if Lim(1) > 0
        xlim(Lim);
    elseif Lim(1)+fs > 0
        xlim([1 Lim(2)-Lim(1)+1]);
    end
    if fs == 1
        Lim = xlim;
        if Lim(1) > 1
            xlim(Lim - 1);
        end
    end
    

%% big_right_Callback
% This function switches to the following time window.
function big_right_Callback(~, ~, handles)
    axes(handles.signal);
    Lim = xlim;
    dt = Lim(2)-Lim(1);
    Lim = Lim+dt+1;
    data = get(handles.signal_matrix, 'Data');
    Limit = max(size(data));
    if Lim(2) <= Limit
        xlim(Lim);
    else
        xlim([Limit-dt Limit]);
    end
    

%% big_left_Callback
% This function switches to the previous time window.
function big_left_Callback(~, ~, handles)
    axes(handles.signal);
    Lim = xlim;
    dt = Lim(2)-Lim(1);
    Lim = Lim-dt-1;
    if Lim(1) > 0
        xlim(Lim);
    else
        xlim([1 dt+1])
    end


%% fs_ClickedCallback
% This function allows to set the sampling frequency, if its value is not
% already inside the time series file.
function fs_ClickedCallback(~, ~, handles)
    try
        fs_check = get(handles.fs_check, 'String');
        data = get(handles.signal_matrix, 'Data');
        locs = get(handles.locs_matrix, 'Data');
        fs = str2double(get(handles.fs_text, 'String'));
        if strcmp(fs, 'not detected')
            fs = 1;
        end
        if fs == 1
            sliding_check = 1;
        else 
            sliding_check = 0;
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
            reset_filtered(handles);
            sigPlot(handles, data, fs, locs, Lim(1)-sliding_check, ...
                Lim(2))
        else
            problem('The sampling frequency is already setted in the file');
        end
    catch
    end


function amplitude_ClickedCallback(~, ~, ~)


%% time_window_ClickedCallback
% This function allows to change the length of the shown time window.
function time_window_ClickedCallback(~, ~, handles)
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
        xticks(0:fs*max(1, floor(tw/10)):limit*fs);
        xticklabels(string([0:max(1, floor(tw/10)):limit]));
        xlim([Lim(1) Lim(1)+tw*fs]);
    catch
    end
    

%% Go_to_ClickedCallback
% This function shown the time window starting with the selected time
% instant.
function Go_to_ClickedCallback(~, ~, handles, time)
    try
        axes(handles.signal);
        maxsize = max(size(get(handles.signal_matrix, 'Data')));
        Lim = xlim;
        if Lim(2) < maxsize
            fs = str2double(get(handles.fs_text, 'String'));
            window = Lim(2)-Lim(1)+1;
            if nargin < 4
                time = value_asking(floor(Lim(1)/fs), 'Go to...', ...
                    'Insert the time you want to inspect', ...
                    floor((maxsize-window)/fs));
            end
            Lim = [time*fs+1, time*fs+window];
            if Lim(1) < 0
                problem('The time cannot be less than 0');
            else
                xlim(Lim);
            end
        else
            problem('The total time series is already showed')
        end
    catch
    end
    

%% zoom_Callback
% This function shown the amplitude of the time series, multiplied by the
% inserted value.
function zoom_Callback(~, ~, handles)
    axis(handles.signal);
    Lim = floor(xlim/str2double(get(handles.fs_text, 'String')));
    sigPlot(handles, get_data(handles), ...
        str2double(get(handles.fs_text, 'String')), ...
        get(handles.locs_matrix, 'Data'), Lim(1), Lim(end));
    
    
%% sigPlot
% This function shows the chosen time window (between t_start and t_end) of
% the time series (data), setting its sampling frequency (fs).
function sigPlot(handles, data, fs, ~, t_start, t_end)
    switch nargin
        case 4
            t_start = 0;
            t_end = str2double(get(handles.time_window_value, 'String'));
    end
    mult = str2double(get(handles.mult, 'String'));
    locs_ind = get(handles.locs_ind, 'Data');
    locs = get(handles.locs_matrix, 'Data');
    axis(handles.signal);
    ax = gca;
    delta = max(max(abs(data)));
    locations = length(locs);
    if locations == 0
        locations = min(size(data));
    end
    selected = sum(locs_ind);
    ylim([0 delta*(locations)]);
    t_end = t_end*fs;
    t_start = t_start*fs+1;
    count = 1;
    for j = 1:locations
        if locs_ind(j) == 1
            plot(data(j,:)*mult+delta*(count),'b');
            try
                chan_name = locs{j};
            catch
                chan_name = string(j);
            end
            ax.Children(1).ButtonDownFcn = strcat('disp(', ...
                eval('strcat("''", chan_name, "''")'),')');
            count = count + 1;
            hold on
        end
    end
    %hold off
    ylim([0 delta*(selected+2)]);
    xlim([t_start t_end]);
    Limit = max(size(data));
    if not(isempty(locs))
        yticks([1:selected]*delta);
        yticklabels(locs(locs_ind == 1));
    end
    xticks(0:fs:Limit);
    xticklabels(string([0:floor(Limit/fs)]));
    time_window(handles)


%% TimeToSave_ClickedCallback
% This function allows to set the length of the time window of the time 
% series which has to be saved.
function TimeToSave_ClickedCallback(~, ~, handles)
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
    

%% tStart_text_Callback
% This function sets the initial instant of the time window of the time
% series which has to be saved.
function tStart_text_Callback(~, ~, handles)
    time_window(handles)
    

%% time_window
% This function shows the initial time instant and the final one of the
% time window which is eventually saved, through a black vertical line and
% a red one, respectively.
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
    d = [];
    for i = 1:length(children)
        if children(i).XData(1) == children(i).XData(2)
            d = [d; i];
        end
    end
    delete(children(d));
    
    xStart = (fs*(tStart) + 1)*ones(1, 2);
    xEnd = fs*(tStart+time)*ones(1, 2);
    verticalLine = [0, ymax];
    width = ceil((window(2)-window(1))/10000);
    plot(xStart, verticalLine, 'k', 'LineWidth', width)
    plot(xEnd, verticalLine, 'r', 'LineWidth', width)
    hold off;
    

%% Run_Callback
% This function saves the time window of the time series between the black
% and the red vertical lines, filtered if the Filtered button is pushed
% (non-filtered otherwise), related to the only shown channels, in a data
% structure containing the parameters used by the toolbox, in a .mat file
% inside a subdirectory of the main data directory.
function Run_Callback(~, ~, handles)
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    subject = get(handles.Title, 'String');
    locs = get(handles.locs_matrix, 'Data');
    [time_series, ~, ~] = get_data(handles);
    tStart = str2double(get(handles.tStart_text, 'String'));
    time_to_save = str2double(get(handles.TimeToSave_text, 'String'));
    fs = str2double(get(handles.fs_text, 'String'));
    locs_ind = get(handles.locs_ind, 'Data');
    
    data = struct();
    data.time_series = time_series(locs_ind == 1, ...
        tStart*fs+1:(tStart+time_to_save)*fs);
    data.fs = fs;
    if not(isempty(locs))
        data.locs = locs(locs_ind == 1);
    end

    if not(exist(strcat(dataPath, 'Extracted'), 'dir'))
        mkdir(dataPath, 'Extracted');
    end
    sub_name = split(subject, '\');
    if length(sub_name) == 1
        sub_name = split(subject, '/');
    end
    if length(sub_name) == 1
        sub_name = subject(14:end);
    else
        sub_name = sub_name{end};
    end
    
    fNyq = fs/2;
    fmin = str2double(get(handles.fmin, 'String'));
    fmax = str2double(get(handles.fmax, 'String'));
    filt_check = str2double(get(handles.filt_button_check, 'String'));
    if filt_check == 1 && not(fmin < 0) && not(fmax > fNyq)
        data.filter_frequency = [fmin fmax];
    end
            
    dataPath = path_check(strcat(dataPath, 'Extracted'));
    dataPath = strcat(dataPath, sub_name, '.mat');
    save(dataPath, 'data');
    success()
    

%% Loc_ClickedCallback
% This function allows to select the file containing the list of locations,
% if they are not already in the time series file.
function Loc_ClickedCallback(~, ~, handles)
    if not(isempty(get(handles.locs_matrix, 'Data')))
        problem('The locations are already present in the file')
        return
    end
    try
        msg = 'Select the file which contains the locations of the signal';
        title = 'Locations file';
        definput = get(handles.aux_loc, 'String');
        if strcmp(definput, 'Static Text')
            definput = 'es. C:\User\Locationsfile.mat';
        end
        filename = file_asking(definput, title, msg);
        [data, ~, locs, chanlocs] = load_data(filename);
        if isempty(locs)
            locs = data;
        end
        if isempty(locs)
            locs = {chanlocs(:).labels};
        end
        if size(locs, 2) > size(locs, 1)
            locs = locs';
        end
        if size(locs, 2) > 1
            try
                locs(:, 2:end) = [];
            catch
                locs{:, 2:end} = [];
            end
        end
        set(handles.locs_matrix, 'Data', locs);
        axis(handles.signal);
        locs_ind = get(handles.locs_ind, 'Data');
        delta = max(max(abs(get(handles.signal_matrix, 'Data'))));
        yticks([1:length(locs)]*delta)
        yticklabels(locs(locs_ind == 1))
        set(handles.aux_loc, 'String', filename);
    catch
    end
    

%% LocsToShow_ClickedCallback
% This function allows to select the channels which have to be shown.
function LocsToShow_ClickedCallback(~, ~, handles)
    locs = get(handles.locs_matrix, 'Data');
    data = get_data(handles);
    fs = str2double(get(handles.fs_text, 'String'));
    current_ind = get(handles.locs_ind, 'Data');
    chanlocs = get(handles.chanlocs, 'Data');
    if not(isempty(chanlocs))
        locs_ind = Athena_locsSelecting(locs, current_ind, chanlocs);
    else
        locs_ind = Athena_locsSelecting(locs, current_ind);
    end
    waitfor(locs_ind);
    figures = findall(0,'type','figure');
    for i = 1:length(figures)
        if strcmpi(figures(i).Name, 'Current channels')
            close(figures(i))
            break;
        end
    end
    selectedLocs = evalin('base', 'Athena_locsSelecting');
    if isobject(selectedLocs)
        close(selectedLocs)
    end
    evalin( 'base', 'clear Athena_locsSelecting' )
    if sum(selectedLocs ~= 0) && not(isobject(selectedLocs))
        locs_ind = zeros(length(locs), 1);
        locs_ind(selectedLocs) = 1;
        set(handles.locs_ind, 'Data', locs_ind);
        sigPlot(handles, data, fs, locs)
    end
    

%% Filter_ClickedCallback
% This function allows to filter the time series, selecting the minimum and
% the maximum time frequency.
function Filter_ClickedCallback(~, ~, handles)
    fs = str2double(get(handles.fs_text, 'String'));
    fmin = str2double(get(handles.fmin, 'String'));
    fmax = min(str2double(get(handles.fmax, 'String')), fs/2);
    [fmin, fmax, check] = band_asking(fmin, fmax);
    if check == 1
        if fmin <= 0 || fmax <= 0
            problem('A cut frequency cannot be less than or equal to 0 Hz')
        elseif fmin >= fmax
            problem(strcat("The maximum cut frequency has to be ", ...
                "higher than the lower cut frequency"))
        elseif fmax > fs/2
            problem(strcat("The maximum cut frequency cannot be ", ...
                "higher than the Nyquist frequency, so it has to be ", ...
                "less than half the sample rate, which is equal to ", ...
                string(fs), " Hz (the maximum value is ", ...
                string(ceil(fs/2)), ")"))
        else
            filter_file = choose_filter(get(handles.filter_name,'String'));
            set(handles.filter_name, 'String', filter_file);
            filter_handle = eval(strcat('@', filter_file));
            f = waitbar(0, 'Initialization', 'Color', '[1 1 1]');
            fchild = allchild(f);
            fchild(1).JavaPeer.setForeground(...
                fchild(1).JavaPeer.getBackground.BLUE)
            fchild(1).JavaPeer.setStringPainted(true)
        
            data = get(handles.signal_matrix, 'Data');
            waitbar(0.33, f , 'Filtering in progress')
            filt_data = filter_handle(data, fs, fmin, fmax);
            waitbar(0.66, f , 'Data setting')
            set(handles.filt_matrix, 'Data', filt_data);
            set(handles.fmin, 'String', char(string(fmin)));
            set(handles.fmax, 'String', char(string(fmax)));
            set(handles.filt_check, 'String', 'filtered');
            close(f)
            Filtered_button_Callback(1, 1, handles)
            Filtered_button_Callback(1, 1, handles)
        end
    end


%% forward_show_ClickedCallback
% This function switches automatically the time window of the time series,
% one second forward per step.
function forward_show_ClickedCallback(hObject, eventdata, handles)
    set_off(handles, 'forward')
    while 1
        if check_off(handles, 'forward')
            set(handles.stop_show, 'State', 'off')
            set(handles.forward_show, 'State', 'off')
            break
        end
        right_Callback(hObject, eventdata, handles)
        pause(1)
    end


%% backwards_show_ClickedCallback
% This function switches automatically the time window of the time series,
% one second backward per step,
function backwards_show_ClickedCallback(hObject, eventdata, handles)
    set_off(handles, 'backwards')
    while 1
        if check_off(handles, 'backwards')
            set(handles.stop_show, 'State', 'off')
            set(handles.back_show, 'State', 'off')
            break
        end
        left_Callback(hObject, eventdata, handles)
        pause(1)
    end


%% big_forward_show_ClickedCallback
% This function switches automatically the time window of the time series,
% one time window forward per step.
function big_forward_show_ClickedCallback(hObject, eventdata, handles)
    set_off(handles, 'big_forward')
    while 1
        if check_off(handles, 'big_forward')
            set(handles.stop_show, 'State', 'off')
            set(handles.big_forward_show, 'State', 'off')
            break
        end
        big_right_Callback(hObject, eventdata, handles)
        pause(1)
    end
    
    
%% big_backwards_show_ClickedCallback
% This function switches automatically the time window of the time series,
% one time window backward per step,
function big_backwards_show_ClickedCallback(hObject, eventdata, handles)
    set_off(handles, 'big_backwards')
    while 1
        if check_off(handles, 'big_backwards')
            set(handles.stop_show, 'State', 'off')
            set(handles.big_back_show, 'State', 'off')
            break
        end
        big_left_Callback(hObject, eventdata, handles)
        pause(1)
    end

    
%% set_off
% This function puts off the automatic time window switchers.
function set_off(handles, hand_name_not)
    hands = {handles.back_show, handles.forward_show, ...
        handles.stop_show, handles.big_back_show, ...
        handles.big_forward_show};
    names = {'backwards', 'forward', 'stop', 'big_backwards', ...
        'big_forward'};
    searchname = cellfun(@(x)isequal(x, hand_name_not), names);
        [~, c] = find(searchname);
        values = {'off', 'off', 'off', 'off', 'off'};
        values{c} = 'on';
    for i = 1:length(values)
        set(hands{i}, 'State', values{i})
    end
    

%% check_off
% This function returns 1 if one of the automatic time window switchers is
% currently running (0 otherwise).
function check = check_off(handles, hand_name)
    check = 0;
    if strcmpi(get(handles.stop_show, 'State'), 'on')
        check = 1;
    else
        names = {'backwards', 'forward', 'big_backwards', 'big_forward'};
        hands = {handles.back_show, handles.forward_show, ...
            handles.big_back_show, handles.big_forward_show};
        searchname = cellfun(@(x)isequal(x, hand_name), names);
        [~, c] = find(searchname);
        values = {'on', 'on', 'on', 'on'};
        values{c} = 'off';
        for i = 1:length(values)
            if strcmpi(get(hands{i}, 'State'), values{i})
                check = 1;
            end
        end
    end
        

%% end_show_ClickedCallback
% This function shows the last time window of the time series.
function end_show_ClickedCallback(~, ~, handles)
    axes(handles.signal);
    final = length(get(handles.signal_matrix, 'Data'));
    Lim = xlim;
    dt = Lim(2)-Lim(1);
    xlim([final-dt final]);
 

%% start_show_ClickedCallback
% This function shows the first time window of the time series.
function start_show_ClickedCallback(~, ~, handles)
    axes(handles.signal);
    Lim = xlim;
    dt = Lim(2)-Lim(1);
    xlim([1 dt+1]);
      

%% stop_show_ClickedCallback
% This function stops the automatic time window switch.
function stop_show_ClickedCallback(~, ~, handles)
    set(handles.big_forward_show, 'State', 'off')
    set(handles.big_back_show, 'State', 'off')
    set(handles.forward_show, 'State', 'off')
    set(handles.back_show, 'State', 'off')
    

%% Filtered_button_Callback
% This function switches between the original time series (released button)
% and the filtered one (pushed button).
function Filtered_button_Callback(~, ~, handles)
    locs = get(handles.locs_matrix, 'Data');
    fs = str2double(get(handles.fs_text, 'String'));
    filt_button_check = get(handles.filt_button_check, 'String');
    if strcmp(get(handles.filt_check, 'String'), 'filtered')
        if strcmp(filt_button_check, '0')
            data = get(handles.filt_matrix, 'Data');
            set(handles.filt_button_check, 'String', '1');
            set(handles.Filtered_button, 'BackgroundColor', ...
                [0.29 0.77 0.69]);
            set(handles.Filtered_button, 'String', 'Filtered')
        else
            data = get(handles.signal_matrix, 'Data');
            set(handles.filt_button_check, 'String', '0');
            set(handles.Filtered_button, 'BackgroundColor', ...
                [0.43 0.8 0.72]);
            set(handles.Filtered_button, 'String', 'Filter')
        end
        axis(handles.signal);
        t = xlim;
        sigPlot(handles, data, fs, locs, floor((t(1)-1)/fs), ...
            floor(t(2)/fs))
    else
        m = "The signal has not been filtered. Do you want to filter it?"; 
        t = 'Filtering';
        if strcmpi(user_decision(m, t), 'yes')
            Filter_ClickedCallback(1, 1, handles)
            Filtered_button_Callback(1, 1, handles)
        end
    end


%% location_index
% This function returns an ones array having the length equal to the number
% of locations of the signal (obtained from locs if it is not empty, from
% data otherwise).
function locs_ind = location_index(locs, data)
    locs_ind = ones(length(locs), 1);
    if isempty(locs_ind)
        locs_ind = ones(min(size(data)), 1);
    end
    

%% reset_filtered
% This function is used when the filtering cut frequencies are changed, in
% order to recompute the filtered signal.
function reset_filtered(handles)
    set(handles.filt_button_check, 'String', '0');
    set(handles.Filtered_button, 'BackgroundColor', [0.43 0.8 0.72]);
    try
        fmin = str2double(get(handles.fmin, 'String'));
        fmax = str2double(get(handles.fmax, 'String'));
        fs = str2double(get(handles.fs_text, 'String'));
        data = get(handles.signal_matrix, 'Data');
        filter_handle = eval(strcat('@', get(handles.filter_name, ...
            'String')));
        filt_data = filter_handle(data, fs, fmin, fmax);
        set(handles.filt_matrix, 'Data', filt_data);
        Filtered_button_Callback(1, 1, handles)
        Filtered_button_Callback(1, 1, handles)
    catch
    end
    
    
%% get_data
% This function is used to return the time series (data), and the minimum
% and the maximum filtering cut frequencies (fmin and fmax, respectively).
function [data, fmin, fmax] = get_data(handles)
    if strcmp(get(handles.filt_button_check, 'String'), '1')
    	data = get(handles.filt_matrix, 'Data');
        fmin = str2double(get(handles.fmin, 'String'));
        fmax = str2double(get(handles.fmax, 'String'));
    else
        data = get(handles.signal_matrix, 'Data');
        fmin = 0;
        fmax = 1000;
    end
 

%% reref_ClickedCallback
% This function is used to rereference the time series, selecting the
% reference through the Rereference Selection interface.
function reref_ClickedCallback(~, ~, handles)
    data = get_data(handles);
    fs = str2double(get(handles.fs_text, 'String'));
    locs = get(handles.locs_matrix, 'Data');
    ref = Athena_reref(locs);
    waitfor(ref);
    selectedLocs = evalin('base', 'Athena_reref');
    if isobject(selectedLocs)
        close(selectedLocs)
        return
    end
    evalin( 'base', 'clear Athena_reref' );
    NLocs = length(selectedLocs);
    baseline = zeros(1, length(data));
    f = waitbar(0, 'Rereferencing', 'Color', '[1 1 1]');
            fchild = allchild(f);
            fchild(1).JavaPeer.setForeground(...
                fchild(1).JavaPeer.getBackground.BLUE)
            fchild(1).JavaPeer.setStringPainted(true)
    for i = 1:NLocs
        if selectedLocs(i) > length(locs)
            baseline = baseline + mean(data);
        else
            baseline = baseline + data(selectedLocs(i), :);
        end
    end
    baseline = baseline/NLocs;
    for i = 1:length(locs)
        data(i, :) = data(i, :)-baseline;
    end
    waitbar(0.5, f)
    set(handles.signal_matrix, 'Data', data);
    reset_filtered(handles)
    close(f)
    axis(handles.signal);
    t = xlim;
    sigPlot(handles, data, fs, locs, floor((t(1)-1)/fs), floor(t(2)/fs))
    
    
%% screen_ClickedCallback
% This function takes a picture of the currently shown time window of the
% time series, and saves it in a subdirectory of the main data directory.
function screen_ClickedCallback(hObject, eventdata, handles)
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    outDir = create_directory(dataPath, 'Images');
    tStart = get(handles.tStart_text, 'String');
    time_to_save = get(handles.TimeToSave_text, 'String');
    time = strcat(tStart, '-', string(str2double(tStart) + ...
        str2double(time_to_save)));
    freq = strcat(get(handles.fmin, 'String'), '-', get(handles.fmax, ...
        'String'));
    subject = split(get(handles.Title, 'String'), 'subject: ');
    subject = subject{2};
    axes(handles.signal)
    Image = getframe(handles.signal);
    for i = 1:6
        aux = 0.15*i*ones(1, 3);
        handles.signal.XColor = aux;
        handles.signal.YColor = aux;
        pause(0.03)
    end
    for i = 1:6
        aux = 0.15*(7-i)*ones(1, 3);
        handles.signal.XColor = aux;
        handles.signal.YColor = aux;
        pause(0.03)
    end
    imwrite(Image.cdata, char_check(strcat(path_check(outDir), ...
        'Signal_', subject, '_', time, '_', freq, 'Hz.jpg')));
  
    
%% subject_selection_ClickedCallback
% This function allows to select the subject which has to be shown.
function subject_selection_ClickedCallback(hObject, eventdata, handles)
    dataPath = get(handles.aux_dataPath, 'String');
    dataPath = path_check(dataPath);
    cases = define_cases(dataPath);
    case_number = str2double(get(handles.case_number, 'String'));
    n = Athena_locsSelecting({cases.name}, case_number, 1);
    waitfor(n);
    case_n = evalin('base', 'Athena_locsSelecting');
    if isobject(case_n)
        close(case_n)
    end
    evalin( 'base', 'clear Athena_locsSelecting' )
    if length(case_n) > 1
        problem('You can select only a subject')
        return
    end
    if not(isobject(case_n)) && case_number ~= case_n
        set(handles.case_number, 'String', string(case_n+1))
        Previous_Callback(hObject, eventdata, handles)
    end
    

%% Home_WindowKeyPressFcn
% This function is used to use a speech command when the spacebar is 
% pressed on the keyboard.
function Home_WindowKeyPressFcn(hObject, eventdata, handles)
    if contains('0123456789', eventdata.Key) || strcmpi(eventdata.Key, ...
            'backspace') || strcmpi(eventdata.Key, 'delete')
        if not(strcmpi(get(handles.tStart_text, 'String'), '0'))
            tStart_text_Callback(hObject, eventdata, handles)
        end
        return;
    end
    if not(strcmpi(eventdata.Key, 'space'))
        return;
    end
    try
        set(handles.recording_button, 'Visible', 'on');
        set(handles.recording_text, 'Visible', 'on');
        pause(0.0000001);
        record = audio_recording(16e3, 2);
        set(handles.recording_button, 'Visible', 'off');
        set(handles.recording_text, 'Visible', 'off');
        recorded_command = classify_command(record, handles.net);  
        if strcmpi(recorded_command, 'up')
            set(handles.mult, 'String', string(str2double(get(...
                handles.mult, 'String'))*10))
            zoom_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'down')
            set(handles.mult, 'String', string(max(1, ...
                str2double(get(handles.mult, 'String'))/10)))
            zoom_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'left')
            left_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'right')
            right_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'backward')
            big_left_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorder_command, 'forward')
            big_right_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'zero')
            Go_to_ClickedCallback(hObject, eventdata, handles, 0)
        elseif strcmpi(recorded_command, 'stop')
            set(handles.big_forward_show, 'State', 'off')
            set(handles.big_back_show, 'State', 'off')
            set(handles.forward_show, 'State', 'off')
            set(handles.back_show, 'State', 'off')
        elseif strcmpi(recorded_command, 'go')
            big_forward_show_ClickedCallback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'on')
            if strcmpi(get(handles.Filtered_button, 'String'), 'Filter')
                Filtered_button_Callback(hObject, eventdata, handles)
            end
        elseif strcmpi(recorded_command, 'off')
            if strcmpi(get(handles.Filtered_button, 'String'), 'Filtered')
                Filtered_button_Callback(hObject, eventdata, handles)
            end
        elseif strcmpi(recorded_command, 'follow')
            axes(handles.signal);
            Lim = xlim;
            fs = str2double(get(handles.fs_text, 'String'));
            set(handles.tStart_text, 'String', string(floor(Lim(1)/fs)))
            tStart_text_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'yes')
        elseif strcmpi(recorded_command, 'no')
        elseif strcmpi(recorded_command, 'unknown') || ...
                strcmpi(recorded_command, 'background')
        end
    catch
    end
  
    
%% Home_KeyPressFcn
% This function is used to use a keyboard command.
function Home_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'leftarrow')
        left_Callback(hObject, eventdata, handles)
    elseif strcmpi(eventdata.Key, 'rightarrow')
        right_Callback(hObject, eventdata, handles)
    elseif strcmpi(eventdata.Key, 'uparrow')
        set(handles.mult, 'String', string(str2double(get(handles.mult, ...
            'String'))*10))
        zoom_Callback(hObject, eventdata, handles)
    elseif strcmpi(eventdata.Key, 'downarrow')
        set(handles.mult, 'String', string(max([1, ...
            str2double(get(handles.mult, 'String'))/10])))
        zoom_Callback(hObject, eventdata, handles)
    elseif strcmpi(eventdata.Key, 'return')
        Filtered_button_Callback(hObject, eventdata, handles)
    end