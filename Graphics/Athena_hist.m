function varargout = Athena_hist(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_hist_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_hist_OutputFcn, ...
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


function Athena_hist_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    set(handles.histogram, 'Units', 'normalized');
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
    

    
function varargout = Athena_hist_OutputFcn(hObject, eventdata, handles) 
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
        axis(handles.histogram);
        axes(handles.histogram);
        [PAT, HC, bins] = histogram_initialization(handles);
        if not(isempty(PAT)) && not(isempty(HC))
            xmax = max(max(max(PAT)), max(max(HC)))*1.1;
            if length(bins) == 1
                bins = linspace(0, xmax, bins+1);
            end
            histogram(HC, bins, 'FaceColor', [0.43, 0.8, 0.72], ...
                'FaceAlpha', 1)
            legend({'group 0'})
            L = ylim;
            ylim([L(1) L(2)*1.1])
            axis(handles.histogram2);
            axes(handles.histogram2);
            histogram(PAT, bins, 'FaceColor', [0.07, 0.12, 0.42], ...
                'FaceAlpha', 1)
            legend({'group 1'})
            L = ylim;
            ylim([L(1) L(2)*1.1])
        elseif not(isempty(PAT))
            xmax = max(max(PAT))*1.1;
            if length(bins) == 1
                bins = linspace(0, xmax, bins+1);
            end
            histogram(PAT, bins, 'FaceColor', [0.07, 0.12, 0.42], ...
                'FaceAlpha', 1)
            legend({'group 1'})
            L = ylim;
            ylim([L(1) L(2)*1.1])
        elseif not(isempty(HC))
            xmax = max(max(HC))*1.1;
            if length(bins) == 1
                bins = linspace(0, xmax, bins+1);
            end
            histogram(HC, bins, 'FaceColor', [0.43, 0.8, 0.72], ...
                'FaceAlpha', 1)
            legend({'group 0'})
            L = ylim;
            ylim([L(1) L(2)*1.1])
        else
            problem('Values not found or not valid.')
            return;
        end
        set(handles.help_button, 'Visible', 'off')
    end
    
    
function [PAT, HC, bins, measure, band, location] = ...
    histogram_initialization(handles)

    dataPath = get(handles.dataPath_text, 'String');
    measure = define_measure(handles);
    
    bands_list = get(handles.band, 'String');
    band = str2double(bands_list(get(handles.band, 'Value')));
    
    areas_list = get(handles.area, 'String');
    area = areas_list(get(handles.area, 'Value'));
    
    measure_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), area));
    
    locations_list = get(handles.loc, 'String');
    check = 0;
    
    bins = 10;
    if get(handles.low, 'Value') == 1
        bins = 5;
    elseif get(handles.high, 'Value') == 1
        bins = 30;
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
    close(Athena_hist)
    Athena_statistics(dataPath, measure, sub, loc)


function export_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.loc, 'Visible'), 'off')
        return;
    end
    if strcmp(get(handles.loc, 'Enable'), 'on') && ...
            strcmp(get(handles.loc, 'Enable'), 'on')
        [PAT, HC, bins, measure, band, location] = ...
            histogram_initialization(handles);
    
        distributions_histogram(HC, PAT, measure, ...
            {'Group 0', 'Group 1'}, location, band, bins)
    end


function meas_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measure = define_measure(handles);
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
    measure = define_measure(handles);
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


function medium_Callback(hObject, eventdata, handles)


function low_Callback(hObject, eventdata, handles)


function measure = define_measure(handles)
    measures_list = get(handles.meas, 'String');
    if ischar(measures_list)
        measure = measures_list;
    else
        measure = measures_list(get(handles.meas, 'Value'));
    end