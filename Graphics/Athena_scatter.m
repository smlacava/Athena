function varargout = Athena_scatter(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_scatter_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_scatter_OutputFcn, ...
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


function Athena_scatter_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
        if not(strcmp(path, 'Static Text'))
            set(handles.dataPath_text, 'String', path)
        end
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    dataPath_text_Callback(hObject, eventdata, handles)
    

    
function varargout = Athena_scatter_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    
    dataPath = get(handles.dataPath_text, 'String');
    if exist(dataPath, 'dir')
        cases = dir(dataPath);
        measures = [];
        for i = 1:length(cases)
        	if cases(i).isdir == 1
                if sum(strcmp(cases(i).name, {'offset', 'exponent', ...
                        'PSDr', 'PLI', 'PLV', 'AEC', 'AECo'}))
                    measures = [measures, string(cases(i).name)];
                end
            end
        end
        set(handles.meas1, 'String', measures)
        set(handles.meas2, 'String', measures)
        set(handles.meas1, 'Value', 1)
        set(handles.meas2, 'Value', 1)
    end
    set(handles.band1, 'Visible', 'off')
    set(handles.band2, 'Visible', 'off')
    set(handles.loc1, 'Visible', 'off')
    set(handles.loc2, 'Visible', 'off')
    set(handles.area1, 'Visible', 'off')
    set(handles.area2, 'Visible', 'off')

    
function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Correlations'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    if strcmp(get(handles.dataPath_text, 'String'), 'es. C:\User\Data')
        problem('You have to select a directory')
    else
        axis(handles.scatter);
        [PAT1, HC1, PAT2, HC2] = measures_scatter_initialization(handles);
        scatter(HC1, HC2, 'b')
        hold on
        scatter(PAT1, PAT2, 'r')
        legend('group 0', 'group 1')
        hold off
        set(handles.help_button, 'Visible', 'off')
    end
    
    
function [PAT1, HC1, PAT2, HC2, measure1, measure2, band1, band2, ...
    location1, location2] = measures_scatter_initialization(handles)

    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas1, 'String');
    measure1 = measures_list(get(handles.meas1, 'Value'));
    measure2 = measures_list(get(handles.meas2, 'Value'));
    
    bands_list1 = get(handles.band1, 'String');
    bands_list2 = get(handles.band2, 'String');
    band1 = str2double(bands_list1(get(handles.band1, 'Value')));
    band2 = str2double(bands_list2(get(handles.band2, 'Value')));
    
    areas_list1 = get(handles.area1, 'String');
    areas_list2 = get(handles.area2, 'String');
    area1 = areas_list1(get(handles.area1, 'Value'));
    area2 = areas_list2(get(handles.area2, 'Value'));
    
    measure1_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure1), path_check('Epmean'), area1));
    measure2_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure2), path_check('Epmean'), area2));
    
    locations_list1 = get(handles.loc1, 'String');
    locations_list2 = get(handles.loc2, 'String');
    check1 = 0;
    check2 = 0;
    
    if sum(contains(measure1_path, {'Asymmetry', 'Global'})) == 0
        location1 = locations_list1(get(handles.loc1, 'Value'));
        check1 = 1;
    end
    if sum(contains(measure2_path, {'Asymmetry', 'Global'})) == 0
        location2 = locations_list2(get(handles.loc2, 'Value'));
        check2 = 1;
    end
    
    [PAT1, ~, locs1] = load_data(strcat(measure1_path, 'PAT.mat'));
    HC1 = load_data(strcat(measure1_path, 'HC.mat'));
    [PAT2, ~, locs2] = load_data(strcat(measure2_path, 'PAT.mat'));
    HC2 = load_data(strcat(measure2_path, 'HC.mat'));
    
    if check1 == 0
        idx_loc1 = 1;
    else
        for i = 1:length(locs1)
            if strcmpi(locs1{i}, location1)
                idx_loc1 = i;
                break;
            end
        end
    end
    if check2 == 0
        idx_loc2 = 1;
    else
        for i = 1:length(locs2)
            if strcmpi(locs2{i}, location2)
                idx_loc2 = i;
                break;
            end
        end
    end
    
    PAT1 = PAT1(:, band1, idx_loc1);
    HC1 = HC1(:, band1, idx_loc1);
    PAT2 = PAT2(:, band2, idx_loc2);
    HC2 = HC2(:, band2, idx_loc2);
    
    if not(exist('location1', 'var'))
        location1 = get(handles.loc1, 'String');
    end
    if not(exist('location2', 'var'))
        location2 = get(handles.loc2, 'String');
    end

function data_search_Callback(hObject, eventdata, handles)
	d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        dataPath_text_Callback(hObject, eventdata, handles)
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
    close(Athena_scatter)
    Athena_an(dataPath, measure, sub, loc)


function export_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.loc1, 'Enable'), 'on') && ...
            strcmp(get(handles.loc1, 'Enable'), 'on')
        [PAT1, HC1, PAT2, HC2, measure1, measure2, band1, band2, ...
            location1, location2] = ...
            measures_scatter_initialization(handles);
    
        figure('Name', strcat(measure1, " ", location1, " Band ", ...
            string(band1), " - ", measure2, " ", location2, " Band ", ...
            string(band2)), 'NumberTitle', 'off', 'ToolBar', 'none');
        set(gcf, 'color', [0.67 0.98 0.92])
        scatter(HC1, HC2, 'b')
        hold on
        scatter(PAT1, PAT2, 'r')
        legend('group 0', 'group 1')
        xlabel(strcat(measure1, " ", location1, " Band ", string(band1)))
        ylabel(strcat(measure2, " ", location2, " Band ", string(band2)))
    end

function loc2_Callback(hObject, eventdata, handles)
    

function loc2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function area2_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas2, 'String');
    measure = measures_list(get(handles.meas2, 'Value'));
    areas_list = get(handles.area2, 'String');
    area = areas_list(get(handles.area2, 'Value'));
    [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), path_check(area), ...
        'PAT.mat'));
    set(handles.loc2, 'Value', 1)
    set(handles.loc2, 'String', locations)
    set(handles.loc2, 'Visible', 'on')


function area2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function band2_Callback(hObject, eventdata, handles)


function band2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function meas2_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas2, 'String');
    measure = measures_list(get(handles.meas2, 'Value'));
    dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    if exist(dataPath, 'dir')
        set(handles.area2, 'String', ["Areas", "Asymmetry", "Global", ...
            "Total"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        set(handles.band2, 'String', string(1:size(data.measure, 1)))
        set(handles.band2, 'Value', 1)
        set(handles.area2, 'Value', 1)
        set(handles.loc2, 'Value', 1)
        set(handles.area2, 'Visible', 'on')
        set(handles.band2, 'Visible', 'on')
        set(handles.loc2, 'Visible', 'off')
        set(handles.area2, 'Enable', 'on')
        set(handles.band2, 'Enable', 'on')
        
    else
        set(handles.area2, 'String', 'Average not found')
        set(handles.area2, 'Enable', 'off')
        set(handles.band2, 'Enable', 'off')
    end


function meas2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function meas1_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas1, 'String');
    measure = measures_list(get(handles.meas1, 'Value'));
    dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    if exist(dataPath, 'dir')
        set(handles.area1, 'String', ["Areas", "Asymmetry", "Global", ...
            "Total"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        set(handles.band1, 'String', string(1:size(data.measure, 1)))
        set(handles.band1, 'Value', 1)
        set(handles.area1, 'Value', 1)
        set(handles.loc1, 'Value', 1)
        set(handles.area1, 'Visible', 'on')
        set(handles.band1, 'Visible', 'on')
        set(handles.loc1, 'Visible', 'off')
         set(handles.area1, 'Enable', 'on')
        set(handles.band1, 'Enable', 'on')
        
    else
        set(handles.area1, 'String', 'Average not found')
        set(handles.area1, 'Enable', 'off')
        set(handles.band1, 'Enable', 'off')
    end


function meas1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function band1_Callback(hObject, eventdata, handles)


function band1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function area1_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas1, 'String');
    measure = measures_list(get(handles.meas1, 'Value'));
    areas_list = get(handles.area1, 'String');
    area = areas_list(get(handles.area1, 'Value'));
    [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), path_check(area), ...
        'PAT.mat'));
    set(handles.loc1, 'Value', 1)
    set(handles.loc1, 'String', locations)
    set(handles.loc1, 'Visible', 'on')


function area1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function loc1_Callback(hObject, eventdata, handles)


function loc1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
