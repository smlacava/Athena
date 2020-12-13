%% Athena_descriptive_statistics
% This interface allows to compute some descriptive statistical parameters,
% and to compare them between the analyzed groups of subjects.


function varargout = Athena_descriptive_statistics(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_descriptive_statistics_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_descriptive_statistics_OutputFcn, ...
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


%% Athena_descriptive_statistics_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_descriptive_statistics_OpeningFcn(hObject, eventdata, handles, varargin)
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
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    dataPath_text_Callback(hObject, eventdata, handles)
    
    
function varargout = Athena_descriptive_statistics_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% dataPath_text_Callback
% This function is called when the dataPath is modified, in order to
% refresh the interface, and to set the available measures.
function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    
    dataPath = get(handles.dataPath_text, 'String');
    subjectsFile = strcat(path_check(dataPath), 'Subjects.mat');
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
    if exist(dataPath, 'dir')
        measures = available_measures(dataPath, 1, 1);
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


%% Run_Callback
% This function computes some descriptive statistical parameters (mean,
% median, min, max, variance, kurtosis, skewness), and allows to compare
% them between the two groups of subjects.
function Run_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.loc, 'Visible'), 'off') 
        areas_list = get(handles.area, 'String');
        area = areas_list(get(handles.area, 'Value'));
        if strcmpi(area, 'Channels') || strcmp(area, 'Areas')
            return;
        end
    end
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Correlations'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    [save_check, format] = Athena_save_figures('Save figure', ...
        'Do you want to save the resulting figure?');
    if strcmp(get(handles.dataPath_text, 'String'), 'es. C:\User\Data')
        problem('You have to select a directory')
    end
    export_Callback(hObject, eventdata, handles)
    if save_check == 1
        [~, measure, area, ~, ~, ...
             ~, ~, band_name] = ...
            descriptive_initialization(handles, 'no');
        outDir = create_directory(get(handles.dataPath_text, ...
            'String'), 'Figures');
        export_Callback(hObject, eventdata, handles, 'no')
        if strcmp(format, '.fig')
            savefig(char_check(strcat(path_check(outDir), ...
                'Descriptive_Statistics_', area, '_', measure, '_', ...
                band_name, format)));
        else
            Image = getframe(gcf);
            imwrite(Image.cdata, char_check(strcat(...
                path_check(outDir), 'Descriptive_Statistics_', area, ...
                '_', measure, '_', band_name, format)));
        end
        close(gcf)
    end
        

%% descriptive_initialization
% This function returns the parameters used to perform the descriptive
% statistical analysis, taking them from the handles (if flag is equal to
% 'yes', then the string representing the command is added to the
% Athena_history array)
function [dataPath, measure, area, band, location, ...
    sub_types, location_name, band_name] = ...
    descriptive_initialization(handles, flag)
    
    if nargin == 1
        flag = '';
    end
    dataPath = get(handles.dataPath_text, 'String');
    measure = options_list(handles.meas);
    
    bands_list = get(handles.band, 'String');
    band = get(handles.band, 'Value');
    band_name = bands_list(band);
    
    areas_list = get(handles.area, 'String');
    if iscell(areas_list)
        area = areas_list(get(handles.area, 'Value'));
    else
        area = areas_list;
    end
    if strcmpi(area, 'Channels')
        area = "Total";
    end
    
    measure_path = measurePath(dataPath, measure, area);
    
    locations_list = get(handles.loc, 'String');
    check = 0;
    
    if sum(contains(measure_path, {'Asymmetry', 'Global'})) == 0
        location = get(handles.loc, 'Value');
        location_name = locations_list(location);
        check = 1;
    else
        location = 1;
        location_name = area;
    end
    
    [~, ~, locs] = load_data(strcat(measure_path, 'Second.mat'));
    
    if check == 0
        idx_loc = 1;
    else
        for i = 1:length(locs)
            if strcmpi(locs{i}, location_name)
                idx_loc = i;
                break;
            end
        end
    end
    
    if not(exist('location', 'var'))
        location_name = get(handles.loc, 'String');
    end
    
    sub_types = get(handles.sub_types, 'Data');
    if strcmp(flag, 'no')
        return
    end
    
    sub_types_list = '{';
    try
        sub_types_list = strcat(sub_types_list, "'", sub_types{1}, "'");
    catch
    end
    try
        sub_types_list = strcat(sub_types_list, ",'", sub_types{2}, "'");
    catch
    end
    sub_types_list = strcat(sub_types_list, '}');
    Athena_history_update(strcat("descriptive_statistical_analysis(", ...
        strcat("'", dataPath, "'"), ',', strcat("'", measure, "'"), ...
        ',', strcat("'", area, "'"), ',', string(band), ',', ...
        string(idx_loc), ',', sub_types_list, ',', ...
        strcat("'", location_name, "'"), ',', strcat("'", band_name, "'"),')'));


%% data_search_Callback
% This function is called when the directory-searcher button is pushed, in
% order to open the file searcher and changes the settings with respect to
% the analyzed study directory.
function data_search_Callback(hObject, eventdata, handles)
	d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        dataPath_text_Callback(hObject, eventdata, handles)
    end


%% back_Callback
% This function switches to the Statistical Analysis Selection interface.
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
    close(Athena_descriptive_statistics)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


%% export_Callback
% This function exports (saves) the resulting descriptive statistical 
% analysis figure.
function export_Callback(hObject, eventdata, handles, flag)
    if nargin == 3
        flag = '';
    end
    
    [dataPath, measure, area, band, location, ...
        sub_types, location_name, band_name] = ...
        descriptive_initialization(handles, flag);
    descriptive_statistical_analysis(dataPath, measure, ...
        area, band, location, sub_types, location_name, ...
        band_name, 1);


%% meas_Callback
% This function is used to set the available parameters for the selected
% measure.
function meas_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measure = options_list(handles.meas);
    dataPath = Athena_measure_path_management(dataPath, measure);
    if exist(dataPath, 'dir')
        set(handles.area, 'String', ["Areas", "Asymmetry", "Global", ...
            "Channels"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        if exist('network_data', 'var')
            data = network_data;
        end
        bands = Athena_bands_management(dataPath, measure, data);
        if iscell(bands) || isstring(bands)
            set(handles.band, 'String', string(bands))
        else
            set(handles.band, 'String', string(1:size(data.measure, 1)))
        end
        set(handles.band, 'Value', 1)
        set(handles.area, 'Value', 1)
        set(handles.loc, 'Value', 1)
        set(handles.area, 'Visible', 'on')
        set(handles.band, 'Visible', 'on')
        set(handles.band_text, 'Visible', 'on')
        set(handles.area_text, 'Visible', 'on')
        set(handles.loc, 'Visible', 'off')
        set(handles.location_text, 'Visible', 'off')
        set(handles.area, 'Enable', 'on')
        set(handles.band, 'Enable', 'on')
        
    else
        set(handles.area, 'String', 'Average not found')
        set(handles.area, 'Enable', 'off')
        set(handles.band, 'Enable', 'off')
        set(handles.area_text, 'Enable', 'off')
        set(handles.band_text, 'Enable', 'off')
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


%% area_Callback
% This function is used to set the locations which are available for the
% selected spatial subdivision, relating to the selected measure
function area_Callback(hObject, eventdata, handles)
    locations = area_definition(handles, handles.meas, handles.area);
    set(handles.loc, 'Value', 1)
    set(handles.loc, 'String', locations)
    if not(strcmpi(locations, 'asymmetry') | strcmpi(locations, 'global'))
        set(handles.loc, 'Visible', 'on')
        set(handles.location_text, 'Visible', 'on')
    else
        set(handles.loc, 'Visible', 'off')
        set(handles.location_text, 'Visible', 'off')
    end

    
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