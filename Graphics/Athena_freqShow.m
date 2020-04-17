function varargout = Athena_freqShow(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_freqShow_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_freqShow_OutputFcn, ...
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

    
function Athena_freqShow_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('logo.png');
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
        f = waitbar(0, 'Initialization', 'Color', '[0.67 0.98 0.92]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(...
            fchild(1).JavaPeer.getBackground.BLUE)
            fchild(1).JavaPeer.setStringPainted(true)
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        if exist(dataPath, 'dir')
            cases = define_cases(dataPath);
            case_name = split(cases(1).name, '.');
            case_name = case_name{1};
            set(handles.Title, 'String', ...
                strcat("    subject: ", case_name));
            [data, fs, locs] = load_data(strcat(dataPath, cases(1).name));
            if size(data, 1) > size(data, 2)
                data = data';
            end
            if isempty(locs)
                NLOC = min(size(data));
                locs = cell(NLOC, 1);
                for i = 1:NLOC
                    locs{i} = char_check(string(i));
                end
            end
            set(handles.locs_ind, 'Data', [1; zeros(length(locs)-1, 1)]);
            set(handles.locs_matrix, 'Data', locs);
            set(handles.signal_matrix, 'Data', data);
            set(handles.case_number, 'String', '1');
            set(handles.time_shown_value, 'Data', [0, 10])
            if not(isempty(fs))
                set(handles.fs_text, 'String', string(fs));
                set(handles.fs_check, 'String', 'detected');
            else
                fs_ClickedCallback(1, 1, handles)
            end
            waitbar(0.5, f)
            close(f)
            freqPlot(handles);
        else
            set(handles.Title, 'String', "    Data directory not found");
        end
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

    
function varargout = Athena_freqShow_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function back_Callback(~, ~, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_freqShow)
    Athena(dataPath, measure, sub, loc)


function signal_CreateFcn(~, ~, ~)


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

    
function Previous_Callback(~, ~, handles)    
    dataPath = get(handles.aux_dataPath, 'String');
    dataPath = path_check(dataPath);
    case_number = str2double(get(handles.case_number, 'String'))-1;
    cases = define_cases(dataPath);
    case_max = length(cases);
    if case_number <= case_max && case_number > 0
        f = waitbar(0, 'Data loading', 'Color', '[0.67 0.98 0.92]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(...
            fchild(1).JavaPeer.getBackground.BLUE)
        fchild(1).JavaPeer.setStringPainted(true)
        [data, fs, locs] = load_data(strcat(dataPath, ...
            cases(case_number).name));
        waitbar(0.5, f, 'Processing your data')
        hold off
        if size(data, 1) > size(data, 2)
            data = data';
        end
        if isempty(locs)
            locs = get(handles.locs_matrix, 'Data');
            check = 0;
            for i = 1:length(locs)
                if not(strcmp(locs{i}, string(i)))
                    check = 1;
                    break;
                end
            end
            if check == 0
                NLOC = min(size(data));
                locs = cell(NLOC, 1);
                for i = 1:NLOC
                    locs{i} = char_check(string(i));
                end
            end    
        end
        locs_ind = 1;
        set(handles.signal_matrix, 'Data', data);
        set(handles.locs_matrix, 'Data', locs);
        set(handles.locs_ind, 'Data', [1; zeros(length(locs)-1, 1)]);
        time = get(handles.time_shown_value, 'Data');
        set(handles.time_shown_value, 'Data', [0, time(2)-time(1)])
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
        close(f)
        freqPlot(handles, data, fs, locs)
        start_show_ClickedCallback(1, 1, handles)
    elseif case_number > length(cases)
        set(handles.case_number, 'String', string(case_max));
    else
        set(handles.case_number, 'String', '1');
    end
    
    
function right_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    time = time+1;
    Limit = max(size(data));
    if time(2)*fs <= Limit
        set(handles.time_shown_value, 'Data', time)
    else
        dt = time(2)-time(1);
        set(handles.time_shown_value, 'Data', [Limit/fs-dt Limit/fs])
    end
    freqPlot(handles, data)
    
    
function left_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    time = time-1;
    if time(1)*fs+1 >= 1
        set(handles.time_shown_value, 'Data', time)
    else
        dt = time(2)-time(1);
        set(handles.time_shown_value, 'Data', [0 dt])
    end
    freqPlot(handles, data)
    
    
function big_right_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    dt = time(2)-time(1);
    time = time+dt;
    Limit = max(size(data));
    if time(2)*fs <= Limit
        set(handles.time_shown_value, 'Data', time)
    else
        set(handles.time_shown_value, 'Data', [Limit/fs-dt, Limit/fs])
    end
    freqPlot(handles, data)
    
    
function big_left_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    dt = time(2)-time(1);
    time = time-dt;
    if time(1)*fs+1 >= 1
        set(handles.time_shown_value, 'Data', time)
    else
        set(handles.time_shown_value, 'Data', [0 dt])
    end
    freqPlot(handles, data)

    
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
        if strcmp(fs_check, 'not detected')
            fs = value_asking(fs, 'Sampling frequency', ...
                    'Insert the sampling frequency of the signal');
            while fs <= 0
                fs = value_asking(fs, 'Sampling frequency', ...
                    'Insert the sampling frequency of the signal');
            end 
            set(handles.fs_text, 'String', string(fs));
            freqPlot(handles)
        else
            problem('The sampling frequency is already setted in the file');
        end
    catch
    end


function amplitude_ClickedCallback(~, ~, ~)


function time_window_ClickedCallback(~, ~, handles)
    try
        [data, fmin, fmax, time, fs] = get_data(handles);
        Limit = max(size(data))/fs;
        initialValue = time(2)-time(1);
        tw = value_asking(initialValue, 'Time window', ...
            'Insert the wished time window', Limit-time(1));
        while tw <= 0
            tw = value_asking(initialValue, 'Time window', ...
                'Insert the wished time window', Limit-time(1));
        end
        if time(1)+tw <= Limit
            set(handles.time_shown_value, 'Data', [time(1), time(1)+tw])
            freqPlot(handles)
        end
    catch
    end
    

function Go_to_ClickedCallback(~, ~, handles)
    try
        [data, fmin, fmax, time, fs] = get_data(handles);
        dt = time(2)-time(1);
        tmax = max(size(data))/fs;
        tmax = tmax-dt;
        tmin = value_asking(time(1), 'Go to...', ...
            'Insert the time you want to inspect', tmax);
        if tmin < 0
            problem('The time cannot be less than 0');
        else
            set(handles.time_shown_value, 'Data', [tmin tmin+dt])
            freqPlot(handles)
        end
    catch
    end
    
    
function freqPlot(handles, varargin)
    try
        locs_ind = get(handles.locs_ind, 'Data');
        locs = get(handles.locs_matrix, 'Data');
        fs = str2double(get(handles.fs_text, 'String'));
        axis(handles.signal);
        [data, fmin, fmax, time_shown] = get_data(handles);
        data(locs_ind==0, :) = [];
        time_string = strcat(string(time_shown(1)), " - ", ...
            string(time_shown(2)), " s");
        try
            location_string = locs{locs_ind == 1};
        catch
            [~, location_string] = max(locs_ind);
            location_string = string(location_string);
        end
        data = data(1, time_shown(1)*fs+1:time_shown(2)*fs);
        [pxx, w] = pwelch(data, [], 0, [], fs);
        plot(w, pxx)
        xlim([fmin, fmax])
        ylim([0, max(max(pxx))])
        set(handles.time_text, 'String', time_string)
        set(handles.loc_shown, 'String', location_string)
    catch
    end
    
    
function Loc_ClickedCallback(~, ~, handles)
    try
        msg = 'Select the file which contains the locations of the signal';
        title = 'Locations file';
        definput = get(handles.aux_loc, 'String');
        if strcmp(definput, 'Static Text')
            definput = 'es. C:\User\Locationsfile.mat';
        end
        filename = file_asking(definput, title, msg);
        [data, ~, locs] = load_data(filename);
        if isempty(locs)
            locs = data;
        end
        locs(:, 2) = [];
        set(handles.locs_matrix, 'Data', locs);
        set(handles.aux_loc, 'String', filename);
        freqPlot(handles)
    catch
    end
    
    
function LocsToShow_ClickedCallback(~, ~, handles)
    locs = get(handles.locs_matrix, 'Data');
    data = get_data(handles);
    fs = str2double(get(handles.fs_text, 'String'));
    current_ind = get(handles.locs_ind, 'Data');
    locs_ind = Athena_locsSelecting(locs, current_ind);
    waitfor(locs_ind);
    selectedLocs = evalin('base', 'Athena_locsSelecting');
    if isobject(selectedLocs)
        close(selectedLocs)
    end
    evalin( 'base', 'clear Athena_locsSelecting' )
    if length(selectedLocs) > 1
        problem("You can select only one location to show")
    elseif sum(selectedLocs ~= 0) && not(isobject(selectedLocs))
        locs_ind = zeros(length(locs), 1);
        locs_ind(selectedLocs) = 1;
        set(handles.locs_ind, 'Data', locs_ind);
        freqPlot(handles, data, fs, locs)
    end

    
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
         
 
 function end_show_ClickedCallback(~, ~, handles)
     axes(handles.signal);
     [data, ~, ~, time, fs] = get_data(handles);
     final = floor(length(data)/fs);
     dt = time(2)-time(1);
     set(handles.time_shown_value, 'Data', [final-dt final]);
     freqPlot(handles)
     
     
 function start_show_ClickedCallback(~, ~, handles)
     axes(handles.signal);
     [data, ~, ~, time, fs] = get_data(handles);
     dt = time(2)-time(1);
     set(handles.time_shown_value, 'Data', [0 dt]);
     freqPlot(handles);
       
 function stop_show_ClickedCallback(~, ~, handles)
     set(handles.big_forward_show, 'State', 'off')
     set(handles.big_back_show, 'State', 'off')
     set(handles.forward_show, 'State', 'off')
     set(handles.back_show, 'State', 'off')
   
    
function locs_ind = location_index(locs, data)
     locs_ind = ones(length(locs), 1);
     if isempty(locs_ind)
         locs_ind = ones(min(size(data)), 1);
     end
    
    
function [data, fmin, fmax, time, fs] = get_data(handles)
    data = get(handles.signal_matrix, 'Data');
    fmin = str2double(get(handles.fmin, 'String'));
    fmax = str2double(get(handles.fmax, 'String'));
    time = get(handles.time_shown_value, 'Data');
    fs = str2double(get(handles.fs_text, 'String'));


function fmin_Callback(hObject, eventdata, handles)
        frequencies = get(handles.freq_matrix, 'Data');
    try
        [~, fmin, fmax] = get_data(handles);
        if fmin >= fmax
            problem(strcat("The minimum frequency cannot be higher ", ...
                "than or equal to the maximum frequency"))
        elseif fmin < 0
            problem('The minimum frequency cannot be less than zero')
        elseif fmin > str2double(get(handles.fs_text, 'String'))/2
            problem(strcat("The minimum frequency cannot be higher ", ...
                "than the Nyquist frequency (", ...
                string(str2double(get(handles.fs_text, 'String'))/2), ")"))
        else
            freqPlot(handles)
            frequencies{1} = fmin;
            set(handles.freq_matrix, 'Data', frequencies)
        end
    catch
        problem("Invalid minimum frequency value")
    end
    set(handles.fmin, 'String', string(frequencies{1}));

    
function fmin_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function fmax_Callback(hObject, eventdata, handles)
    frequencies = get(handles.freq_matrix, 'Data');
    try
        [~, fmin, fmax] = get_data(handles);
        if fmin >= fmax
            problem(strcat("The maximum frequency cannot be lower ", ...
                "than or equal to the minimum frequency"))
        elseif fmax < 0
            problem('The maximum frequency cannot be less than zero')
        elseif fmax > str2double(get(handles.fs_text, 'String'))/2
            problem(strcat("The maximum frequency cannot be higher ", ...
                "than the Nyquist frequency (", ...
                string(str2double(get(handles.fs_text, 'String'))/2), ")"))
        else
            freqPlot(handles)
            frequencies{2} = fmax;
            set(handles.freq_matrix, 'Data', frequencies)
        end
    catch
        problem("Invalid maximum frequency value")
    end
    set(handles.fmax, 'String', string(frequencies{2}));
    
function fmax_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
