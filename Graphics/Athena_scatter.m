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
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
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
        cases = dir(dataPath);
        measures = [];
        for i = 1:length(cases)
        	if cases(i).isdir == 1
                if sum(strcmp(cases(i).name, {'offset', 'exponent', ...
                        'PSDr', 'PLI', 'PLV', 'AEC', 'AECo', 'coherence'}))
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
    set(handles.band1_text, 'Visible', 'off')
    set(handles.band2_text, 'Visible', 'off')
    set(handles.location1_text, 'Visible', 'off')
    set(handles.location2_text, 'Visible', 'off')
    set(handles.area1_text, 'Visible', 'off')
    set(handles.area2_text, 'Visible', 'off')

    
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
    
    [save_check, format] = Athena_save_figures('Save figure', ...
        'Do you want to save the resulting figure?');
    
    sub_types = get(handles.sub_types, 'Data');
    if strcmp(get(handles.loc1, 'Visible'), 'off') || ...
            strcmp(get(handles.loc2, 'Visible'), 'off') 
        areas1_list = get(handles.area1, 'String');
        area1 = areas1_list(get(handles.area1, 'Value'));
        areas2_list = get(handles.area2, 'String');
        area2 = areas2_list(get(handles.area2, 'Value'));
        if ((strcmpi(area1, 'Channels') || strcmp(area1, 'Areas')) &&  ...
                strcmp(get(handles.loc1, 'Visible'), 'off')) || ...
                ((strcmpi(area2, 'Channels') || strcmp(area2, 'Areas')) ...
                && strcmp(get(handles.loc2, 'Visible'), 'off'))
            return;
        end
    end
    if strcmp(get(handles.dataPath_text, 'String'), 'es. C:\User\Data')
        problem('You have to select a directory')
    else
        axis(handles.scatter);
        [PAT1, HC1, PAT2, HC2, measure1, measure2, band_name1, ...
            band_name2, location1, location2] = ...
            measures_scatter_initialization(handles);
        scatter(HC1, HC2, 'b')
        hold on
        scatter(PAT1, PAT2, 'r')
        legend(sub_types)
        hold off
        if save_check == 1
            outDir = create_directory(get(handles.dataPath_text, ...
                'String'), 'Figures');
            export_Callback(hObject, eventdata, handles)
            if strcmp(format, '.fig')
                savefig(char_check(strcat(path_check(outDir), ...
                    'Scatter_', measure1, band_name1, location1, '_', ...
                    measure2, band_name2, location2, format)));
            else
                Image = getframe(gcf);
                imwrite(Image.cdata, char_check(strcat(...
                    path_check(outDir), 'Scatter_', measure1, ...
                    band_name1, location1, '_', measure2, band_name2, ...
                    location2, format)));
            end
            close(gcf)
        end
        set(handles.help_button, 'Visible', 'off')
    end
    
    
function [PAT1, HC1, PAT2, HC2, measure1, measure2, band_name1, ...
    band_name2, location1, location2] = ...
    measures_scatter_initialization(handles)

    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas1, 'String');
    if iscell(measures_list)
        measure1 = measures_list(get(handles.meas1, 'Value'));
        measure2 = measures_list(get(handles.meas2, 'Value'));
    else 
        measure1 = measures_list;
        measure2 = measures_list;
    end
    
    bands_list1 = get(handles.band1, 'String');
    bands_list2 = get(handles.band2, 'String');
    band1 = get(handles.band1, 'Value');
    band2 = get(handles.band2, 'Value');
    band_name1 = bands_list1(band1);
    band_name2 = bands_list2(band2);
    
    areas1_list = get(handles.area1, 'String');
    if iscell(areas1_list)
        area1 = areas1_list(get(handles.area1, 'Value'));
    else
        area1 = areas1_list;
    end
    if strcmpi(area1, 'Channels')
        area1 = "Total";
    end
    areas2_list = get(handles.area2, 'String');
    if iscell(areas2_list)
        area2 = areas2_list(get(handles.area2, 'Value'));
    else
        area2 = area2_list;
    end
    if strcmpi(area2, 'Channels')
        area2 = "Total";
    end
    
    measure1_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure1), path_check('Epmean'), area1));
    measure2_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure2), path_check('Epmean'), area2));
    
    locations_list1 = get(handles.loc1, 'String');
    locations_list2 = get(handles.loc2, 'String');
    location1 = area1;
    location2 = area2;
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
    
    [PAT1, ~, locs1] = load_data(strcat(measure1_path, 'Second.mat'));
    HC1 = load_data(strcat(measure1_path, 'First.mat'));
    [PAT2, ~, locs2] = load_data(strcat(measure2_path, 'Second.mat'));
    HC2 = load_data(strcat(measure2_path, 'First.mat'));
    
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
    
    sub_types = get(handles.sub_types, 'Data');
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
    
    Athena_history_update(strcat("scatter_analysis(", ...
        strcat("'", dataPath, "'"), ',', strcat("'", measure1, "'"), ...
        ',', strcat("'", measure2, "'"), ',', strcat("'", area1, "'"), ...
        ',', strcat("'", area2, "'"), ',', string(band1), ',', ...
        string(band2), ',', string(idx_loc1), ',', string(idx_loc2), ...
        ',', strcat("'", location1, "'"), ',', ...
        strcat("'", location2, "'"), ',', strcat("'", band_name1, "'"), ...
        ',', strcat("'", band_name2, "'"), ',', sub_types_list, ')'));
    

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
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_scatter)
    Athena_an(dataPath, measure, sub, loc, sub_types)


function export_Callback(hObject, eventdata, handles)
    sub_types = get(handles.sub_types, 'Data');
    if strcmp(get(handles.loc1, 'Visible'), 'off') || ...
            strcmp(get(handles.loc2, 'Visible'), 'off') 
        areas1_list = get(handles.area1, 'String');
        area1 = areas1_list(get(handles.area1, 'Value'));
        areas2_list = get(handles.area2, 'String');
        area2 = areas2_list(get(handles.area2, 'Value'));
        if ((strcmpi(area1, 'Channels') || strcmp(area1, 'Areas')) &&  ...
                strcmp(get(handles.loc1, 'Visible'), 'off')) || ...
                ((strcmpi(area2, 'Channels') || strcmp(area2, 'Areas')) ...
                && strcmp(get(handles.loc2, 'Visible'), 'off'))
            return;
        end
    end
    if strcmp(get(handles.loc1, 'Enable'), 'on') && ...
            strcmp(get(handles.loc1, 'Enable'), 'on')
        [PAT1, HC1, PAT2, HC2, measure1, measure2, band1, band2, ...
            location1, location2] = ...
            measures_scatter_initialization(handles);
        
        figure('Name', strcat(measure1, " ", location1, " Band ", ...
            string(band1), " - ", measure2, " ", location2, " Band ", ...
            string(band2)), 'NumberTitle', 'off', 'ToolBar', 'none');
        set(gcf, 'color', [1 1 1])
        scatter(HC1, HC2, 'b')
        hold on
        scatter(PAT1, PAT2, 'r')
        legend(sub_types)
        xlabel(strcat(measure1, " ", location1, " ", string(band1)))
        ylabel(strcat(measure2, " ", location2, " ", string(band2)))
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
    if iscell(measures_list)
        measure = measures_list(get(handles.meas2, 'Value'));
    else
        measure = measures_list;
    end
    areas_list = get(handles.area2, 'String');
    area = areas_list(get(handles.area2, 'Value'));
    if strcmpi(area, 'Channels')
        area = "Total";
    end
    [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), path_check(area), ...
        'Second.mat'));
    set(handles.loc2, 'Value', 1)
    set(handles.loc2, 'String', locations)
    if not(strcmpi(locations, 'asymmetry') | strcmpi(locations, 'global'))
        set(handles.loc2, 'Visible', 'on')
        set(handles.location2_text, 'Visible', 'on')
    else
        set(handles.loc2, 'Visible', 'off')
        set(handles.location2_text, 'Visible', 'off')
    end


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
    if iscell(measures_list)
        measure = measures_list(get(handles.meas2, 'Value'));
    else
        measure = measures_list;
    end
    dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    if exist(dataPath, 'dir')
        set(handles.area2, 'String', ["Areas", "Asymmetry", "Global", ...
            "Total"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        bands = define_bands(limit_path(dataPath, 'Epmean'), ...
            size(data.measure, 1));
        if iscell(bands) || isstring(bands)
            set(handles.band2, 'String', string(bands))
        else
            set(handles.band2, 'String', string(1:size(data.measure, 1)))
        end
        set(handles.band2, 'Value', 1)
        set(handles.area2, 'Value', 1)
        set(handles.loc2, 'Value', 1)
        set(handles.area2, 'Visible', 'on')
        set(handles.band2, 'Visible', 'on')
        set(handles.band2_text, 'Visible', 'on')
        set(handles.area2_text, 'Visible', 'on')
        set(handles.loc2, 'Visible', 'off')
        set(handles.location2_text, 'Visible', 'off')
        set(handles.area2, 'Enable', 'on')
        set(handles.band2, 'Enable', 'on')
        
    else
        set(handles.area2, 'String', 'Average not found')
        set(handles.area2, 'Enable', 'off')
        set(handles.band2, 'Enable', 'off')
        set(handles.area2_text, 'Enable', 'off')
        set(handles.band2_text, 'Enable', 'off')
    end


function meas2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function meas1_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(handles.meas1, 'String');
    if iscell(measures_list)
        measure = measures_list(get(handles.meas1, 'Value'));
    else
        measure = measures_list;
    end
    dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    if exist(dataPath, 'dir')
        set(handles.area1, 'String', ["Areas", "Asymmetry", "Global", ...
            "Channels"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        bands = define_bands(limit_path(dataPath, 'Epmean'), ...
            size(data.measure, 1));
        if iscell(bands) || isstring(bands)
            set(handles.band1, 'String', string(bands))
        else
            set(handles.band1, 'String', string(1:size(data.measure, 1)))
        end
        set(handles.band1, 'Value', 1)
        set(handles.area1, 'Value', 1)
        set(handles.loc1, 'Value', 1)
        set(handles.area1, 'Visible', 'on')
        set(handles.band1, 'Visible', 'on')
        set(handles.band1_text, 'Visible', 'on')
        set(handles.area1_text, 'Visible', 'on')
        set(handles.loc1, 'Visible', 'off')
        set(handles.location1_text, 'Visible', 'off')
        set(handles.area1, 'Enable', 'on')
        set(handles.band1, 'Enable', 'on')
        
    else
        set(handles.area1, 'String', 'Average not found')
        set(handles.area1, 'Enable', 'off')
        set(handles.band1, 'Enable', 'off')
        set(handles.area1_text, 'Enable', 'off')
        set(handles.band1_text, 'Enable', 'off')
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
    if iscell(measures_list)
        measure = measures_list(get(handles.meas1, 'Value'));
    else
        measure = measures_list;
    end
    areas_list = get(handles.area1, 'String');
    area = areas_list(get(handles.area1, 'Value'));
    if strcmpi(area, 'Channels')
        area = "Total";
    end
    [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), path_check(area), ...
        'Second.mat'));
    set(handles.loc1, 'Value', 1)
    set(handles.loc1, 'String', locations)
    if not(strcmpi(locations, 'asymmetry') | strcmpi(locations, 'global'))
        set(handles.loc1, 'Visible', 'on')
        set(handles.location1_text, 'Visible', 'on')
    else
        set(handles.loc1, 'Visible', 'off')
        set(handles.location1_text, 'Visible', 'off')
    end


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
