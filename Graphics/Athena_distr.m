function varargout = Athena_distr(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_distr_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_distr_OutputFcn, ...
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


function Athena_distr_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    set(handles.scatter, 'Units', 'normalized');
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
    

    
function varargout = Athena_distr_OutputFcn(hObject, eventdata, handles) 
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
        set(handles.meas, 'String', measures)
        set(handles.meas, 'Value', 1)
    end
    set(handles.band, 'Visible', 'off')
    set(handles.loc, 'Visible', 'off')
    set(handles.area, 'Visible', 'off')

    
function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.loc, 'Visible'), 'off')
        return;
    end
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
        [PAT, HC, parameter] = distributions_initialization(handles);
        if strcmpi(parameter, 'mean')
            m1 = mean(HC);
            m2 = mean(PAT);
        else
            m1 = median(HC);
            m2 = median(PAT);
        end
        scatter(linspace(0.4, 0.6, length(HC)), HC, 'b')
        hold on
        scatter(linspace(1.4, 1.6, length(PAT)), PAT, 'r')
        plot([0.3, 0.7], [m1, m1], 'k')
        plot([1.3, 1.7], [m2, m2], 'k')
        xlim([0, 2]);
        legend({'group 0', 'group 1'})
        hold off
        set(handles.help_button, 'Visible', 'off')
    end
    
    
function [PAT, HC, parameter, measure, band, location] = ...
    distributions_initialization(handles)

    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas, 'String');
    measure = measures_list(get(handles.meas, 'Value'));
    
    bands_list = get(handles.band, 'String');
    band = str2double(bands_list(get(handles.band, 'Value')));
    
    areas_list = get(handles.area, 'String');
    area = areas_list(get(handles.area, 'Value'));
    
    measure_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), area));
    
    locations_list = get(handles.loc, 'String');
    check = 0;
    
    if get(handles.mean, 'Value') == 1
        parameter = 'mean';
    else
        parameter = 'median';
    end
    
    if sum(contains(measure_path, {'Asymmetry', 'Global'})) == 0
        location = locations_list(get(handles.loc, 'Value'));
        check = 1;
    end
    
    [PAT, ~, locs] = load_data(strcat(measure_path, 'PAT.mat'));
    HC = load_data(strcat(measure_path, 'HC.mat'));
    
    if check == 0
        idx_loc = 1;
    else
        for i = 1:length(locs)
            if strcmpi(locs{i}, location)
                idx_loc = i;
                break;
            end
        end
    end
    
    PAT = PAT(:, band, idx_loc);
    HC = HC(:, band, idx_loc);
    
    if not(exist('location', 'var'))
        location = get(handles.loc, 'String');
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
    close(Athena_distr)
    Athena_statistics(dataPath, measure, sub, loc)


function export_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.loc, 'Visible'), 'off')
        return;
    end
    if strcmp(get(handles.loc, 'Enable'), 'on') && ...
            strcmp(get(handles.loc, 'Enable'), 'on')
        [PAT, HC, parameter, measure, band, location] = ...
            distributions_initialization(handles);
    
        distributions_scatterplot(HC, PAT, measure, ...
            {'Group 0', 'Group 1'}, location, band, parameter)
    end


function meas_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas, 'String');
    measure = measures_list(get(handles.meas, 'Value'));
    dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    if exist(dataPath, 'dir')
        set(handles.area, 'String', ["Areas", "Asymmetry", "Global", ...
            "Total"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        set(handles.band, 'String', string(1:size(data.measure, 1)))
        set(handles.band, 'Value', 1)
        set(handles.area, 'Value', 1)
        set(handles.loc, 'Value', 1)
        set(handles.area, 'Visible', 'on')
        set(handles.band, 'Visible', 'on')
        set(handles.loc, 'Visible', 'off')
        set(handles.area, 'Enable', 'on')
        set(handles.band, 'Enable', 'on')
        
    else
        set(handles.area, 'String', 'Average not found')
        set(handles.area, 'Enable', 'off')
        set(handles.band, 'Enable', 'off')
    end


function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function band_Callback(hObject, eventdata, handles)


function band_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function area_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas, 'String');
    measure = measures_list(get(handles.meas, 'Value'));
    areas_list = get(handles.area, 'String');
    area = areas_list(get(handles.area, 'Value'));
    [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), path_check(area), ...
        'PAT.mat'));
    set(handles.loc, 'Value', 1)
    set(handles.loc, 'String', locations)
    set(handles.loc, 'Visible', 'on')


function area_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function loc_Callback(hObject, eventdata, handles)


function loc_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function mean_Callback(hObject, eventdata, handles)


function median_Callback(hObject, eventdata, handles)
