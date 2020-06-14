function varargout = Athena_utest(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_utest_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_utest_OutputFcn, ...
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

    
function Athena_utest_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
        if not(strcmp(path, 'Static Text')) && ...
                not(strcmp(measure, 'Static Text'))
            dataPath = strcat(path_check(path), measure);
            set(handles.dataPath_text, 'String', dataPath)
        end
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        loc = varargin{4};
        if not(strcmp(loc, 'Static Text'))
            set(handles.aux_loc, 'String', loc)
        end
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    hands = [handles.asy_button, handles.tot_button, ...
        handles.glob_button, handles.areas_button];
    types = {'Asymmetry', 'Total', 'Global', 'Areas'};
    for i = 1:length(types)
        try
            load(strcat(path_check(path), path_check(measure), ...
                path_check('Epmean'), path_check(types{i}), 'Second.mat'))
            if isempty(Second.data)
                set(hands(i), 'Enable', 'off')
            else
                load(strcat(path_check(path), path_check(measure), ...
                    path_check('Epmean'), path_check(types{i}), ...
                    'First.mat'))
                if isempty(First.data)
                    set(hands(i), 'Enable', 'off')
                end
            end
        catch
            set(hands(i), 'Enable', 'off')
        end
    end
            
                

    
function varargout = Athena_utest_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    dataPath = get(handles.dataPath_text, 'String');
    subjectsFile = strcat(path_check(limit_path(dataPath, ...
        get(handles.aux_measure, 'String'))), 'Subjects.mat');
    if exist(subjectsFile, 'file')
        set(handles.aux_sub, 'String', subjectsFile)
        try
            sub_info = load(subjectsFile);
            aux_sub_info = fields(sub_info);
            eval(strcat("sub_info = sub_info.", aux_sub_info{1}, ";"));
            sub_types = categories(categorical(sub_info(:, end)));
            if length(sub_types) == 2
                set(handles.sub_types, 'Data', sub_types)
            end
        catch
        end
    end


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    save_check = 0;
    if strcmpi(user_decision(...
            'Do you want to save the resulting tables?', 'U Test'), 'yes')
        save_check = 1;
    end
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    measure = get(handles.aux_measure, 'String');
    measures = {'PLI', 'PLV', 'PSDr', 'AEC', 'AECo', 'offset', 'exponent'};
    for i = 1:length(measures)
        if strcmpi(measures{i}, dataPath(end-length(measures{i}):end-1))
            measure = measures{i};
        end
    end
    if not(exist(dataPath, 'dir'))
    	problem(strcat("Directory ", dataPath, " not found"));
        return;
    end
    
    cons = [0 1];
    cons_selected = [get(handles.minCons, 'Value'), ...
        get(handles.maxCons, 'Value')];
    cons(cons_selected == 0) = [];
    
    an_selected = [get(handles.asy_button, 'Value'), ...
        get(handles.tot_button, 'Value'), ...
        get(handles.glob_button, 'Value'), ...
        get(handles.areas_button, 'Value')];
    an_paths = {'Asymmetry', 'Total', 'Global', 'Areas'};
    analysis = an_paths(an_selected == 1);
    
    data_name = strcat(path_check(dataPath), path_check('Epmean'), ...
        path_check(char_check(analysis)));
    try
        [HC, ~, locs] = load_data(strcat(data_name, 'First.mat'));
        PAT = load_data(strcat(data_name, 'Second.mat'));
    catch
        problem(strcat(measure, " epochs averaging of not computed"));
        return;
    end
    
    statistical_analysis(HC, PAT, locs, cons, dataPath, measure, ...
        analysis, get(handles.sub_types, 'Data'), save_check);

    
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        auxPath = pwd;
        dataPath = get(handles.dataPath_text, 'String');
        dataPath = path_check(dataPath);
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
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


function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_utest)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


function axes3_CreateFcn(hObject, eventdata, handles)


function aux_loc_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
