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
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
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
                        'PSDr', 'PLI', 'PLV', 'AEC', 'AECo', 'MSC', ...
                        'coherence'}))
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
    
    sub_types = get(handles.sub_types, 'Data');
    if strcmp(get(handles.dataPath_text, 'String'), 'es. C:\User\Data')
        problem('You have to select a directory')
    else
        axis(handles.scatter);
        [PAT, HC, parameter, measure, band_name] = ...
            distributions_initialization(handles);
        if strcmpi(parameter, 'mean')
            m1 = mean(HC);
            m2 = mean(PAT);
        else
            m1 = median(HC);
            m2 = median(PAT);
        end
        max_lim = 1;
        min_lim = 1;
        list = {};
        if not(isempty(HC))
            scatter(linspace(0.4, 0.6, length(HC)), HC, 36, ...
                [0.43, 0.8, 0.72])
            hold on
            min_lim = 0;
            list = [list, sub_types{1}];
        end
        if not(isempty(PAT))
            scatter(linspace(1.4, 1.6, length(PAT)), PAT, 36, ...
                [0.07, 0.12, 0.42])
            hold on
            max_lim = 2;
            list = [list, sub_types{2}];
        end
        if not(isempty(HC))
            plot([0.3, 0.7], [m1, m1], 'k')
        end
        if not(isempty(PAT))
            plot([1.3, 1.7], [m2, m2], 'k')
        end
        xlim([min_lim, max_lim]);
        legend(list)
        hold off
        set(handles.scatter, 'XTick', [])
        set(handles.help_button, 'Visible', 'off')
        
        if save_check == 1
            outDir = create_directory(get(handles.dataPath_text, ...
                'String'), 'Figures');
            export_Callback(hObject, eventdata, handles, 'no')
            if strcmp(format, '.fig')
                savefig(char_check(strcat(path_check(outDir), ...
                    'Distribution_', area, '_', measure, '_', ...
                    band_name, format)));
            else
                Image = getframe(gcf);
                imwrite(Image.cdata, char_check(strcat(...
                    path_check(outDir), 'Distribution_', area, '_', ...
                    measure, '_', band_name, format)));
            end
            close(gcf)
        end
    end
    
    
function [PAT, HC, parameter, measure, band_name, location] = ...
    distributions_initialization(handles, flag)
    
    if nargin == 1
        flag = '';
    end
    dataPath = get(handles.dataPath_text, 'String');
    measure = define_measure(handles);
    
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
    
    [PAT, ~, locs] = load_data(strcat(measure_path, 'Second.mat'));
    HC = load_data(strcat(measure_path, 'First.mat'));
    
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
    
    if strcmp(flag, 'no')
        return
    end
    
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
    Athena_history_update(strcat("distribution_scatterplot_analysis(", ...
        strcat("'", dataPath, "'"), ',', strcat("'", measure, "'"), ...
        ',', strcat("'", area, "'"), ',', string(band), ',', ...
        string(idx_loc), ',', sub_types_list, ',', ...
        strcat("'", parameter, "'"), ',', ...
        strcat("'", location, "'"), ',', strcat("'", band_name, "'"),')'));

    
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
    close(Athena_distr)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


function export_Callback(hObject, eventdata, handles, flag)
    if nargin == 3
        flag = '';
    end
    
    if strcmp(get(handles.loc, 'Visible'), 'off') 
        areas_list = get(handles.area, 'String');
        area = areas_list(get(handles.area, 'Value'));
        if strcmpi(area, 'Channels') || strcmp(area, 'Areas')
            return;
        end
    end
    sub_types = get(handles.sub_types, 'Data');
    if strcmp(get(handles.loc, 'Enable'), 'on') && ...
            strcmp(get(handles.loc, 'Enable'), 'on')
        [PAT, HC, parameter, measure, band, location] = ...
            distributions_initialization(handles, flag);
    
        distributions_scatterplot(HC, PAT, measure, sub_types, ...
            location, band, parameter)
    end


function meas_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measure = define_measure(handles);
    dataPath = strcat(path_check(dataPath), path_check(measure), ...
            path_check('Epmean'));
    if exist(dataPath, 'dir')
        set(handles.area, 'String', ["Areas", "Asymmetry", "Global", ...
            "Channels"])
        cases = define_cases(dataPath);
        load(strcat(dataPath, cases(1).name));
        bands = define_bands(limit_path(dataPath, 'Epmean'), ...
            size(data.measure, 1));
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


function area_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    measure = define_measure(handles);
    areas_list = get(handles.area, 'String');
    area = areas_list(get(handles.area, 'Value'));
    if strcmpi(area, 'Channels')
        area = "Total";
    end
    [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), path_check(area), ...
        'First.mat'));
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


function mean_Callback(hObject, eventdata, handles)


function median_Callback(hObject, eventdata, handles)


function measure = define_measure(handles)
    measures_list = get(handles.meas, 'String');
    if iscell(measures_list)
        measure = measures_list{get(handles.meas, 'Value')};
    else
    	measure = measures_list;
    end
