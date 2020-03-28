function varargout = Athena_statan(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_statan_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_statan_OutputFcn, ...
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

    
function Athena_statan_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3, 'Units', 'pixels');
    resizePos = get(handles.axes3, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
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
    if nargin == 7
        loc = varargin{4};
        if not(strcmp(loc, 'Static Text'))
            set(handles.aux_loc, 'String', loc)
        end
    end
    hands = [handles.asy_button, handles.tot_button, ...
        handles.glob_button, handles.areas_button];
    types = {'Asymmetry', 'Total', 'Global', 'Areas'};
    for i = 1:length(types)
        try
            load(strcat(path_check(path), path_check(measure), ...
                path_check('Epmean'), path_check(types{i}), 'PAT.mat'))
            if isempty(PAT.data)
                set(hands(i), 'Enable', 'off')
            else
                load(strcat(path_check(path), path_check(measure), ...
                    path_check('Epmean'), path_check(types{i}), 'HC.mat'))
                if isempty(HC.data)
                    set(hands(i), 'Enable', 'off')
                end
            end
        catch
            set(hands(i), 'Enable', 'off')
        end
    end
            
                

    
function varargout = Athena_statan_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    im = imread('untitled3.png');
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
        [HC, ~, locs] = load_data(strcat(data_name, 'HC.mat'));
        PAT = load_data(strcat(data_name, 'PAT.mat'));
    catch
        problem(strcat(measure, " epochs averaging of not computed"));
        return;
    end
    
    statistical_analysis(HC, PAT, locs, cons, dataPath, measure, analysis);

    
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
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_statan)
    Athena_an(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)


function aux_loc_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
