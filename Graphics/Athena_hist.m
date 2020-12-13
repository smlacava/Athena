%% Athena_hist
% This interface allows to show the histogram related to a chosen measure,
% selecting the properly parameters, comparing the histograms if the
% subjects belong to different groups.


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


%% Athena_hist_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
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
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    dataPath_text_Callback(hObject, eventdata, handles)
    
   
function varargout = Athena_hist_OutputFcn(hObject, eventdata, handles) 
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
% This function is executed when the Run button is pushed, and it execute
% the histogram analysis.
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
        axis(handles.histogram);
        axes(handles.histogram);
        [PAT, HC, bins, measure, band_name, location] = ...
            histogram_initialization(handles);
        if not(isempty(PAT)) && not(isempty(HC))
            xmax = max(max(max(PAT)), max(max(HC)))*1.1;
            if length(bins) == 1
                bins = linspace(0, xmax, bins+1);
            end
            set(handles.aux_bar, 'Visible', 'on')
            set(handles.histogram2, 'Visible', 'on')
            set(handles.histogram, 'Position', [0.4825 0.1875 0.498 0.31])
            set(handles.histogram2, 'Position', [0.4825 0.5622 0.498 0.31])
            histogram(HC, bins, 'FaceColor', [0.43, 0.8, 0.72], ...
                'FaceAlpha', 1)
            legend(sub_types(1))
            L = ylim;
            ylim([L(1) L(2)*1.1])
            axis(handles.histogram2);
            axes(handles.histogram2);
            histogram(PAT, bins, 'FaceColor', [0.07, 0.12, 0.42], ...
                'FaceAlpha', 1)
            legend(sub_types(2))
            L = ylim;
            ylim([L(1) L(2)*1.1])
        elseif not(isempty(PAT))
            set(handles.histogram2, 'Visible', 'off')
            set(handles.aux_bar, 'Visible', 'off')
            set(handles.histogram, 'Position', ...
                [0.4825 0.1875 0.498 0.6847])
            xmax = max(max(PAT))*1.1;
            if length(bins) == 1
                bins = linspace(0, xmax, bins+1);
            end
            histogram(PAT, bins, 'FaceColor', [0.07, 0.12, 0.42], ...
                'FaceAlpha', 1)
            legend(sub_types(2))
            L = ylim;
            ylim([L(1) L(2)*1.1])
        elseif not(isempty(HC))
            set(handles.histogram2, 'Visible', 'off')
            set(handles.aux_bar, 'Visible', 'off')
            set(handles.histogram, 'Position', ...
                [0.4825 0.1875 0.498 0.6847])
            xmax = max(max(HC))*1.1;
            if length(bins) == 1
                bins = linspace(0, xmax, bins+1);
            end
            histogram(HC, bins, 'FaceColor', [0.43, 0.8, 0.72], ...
                'FaceAlpha', 1)
            legend(sub_types(1))
            L = ylim;
            ylim([L(1) L(2)*1.1])
        else
            problem('Values not found or not valid.')
            return;
        end
        set(handles.help_button, 'Visible', 'off')
        if save_check == 1
            outDir = create_directory(get(handles.dataPath_text, ...
                'String'), 'Figures');
            export_Callback(hObject, eventdata, handles, 'no')
            if strcmp(format, '.fig')
                savefig(char_check(strcat(path_check(outDir), ...
                    'Histogram_', location, '_', measure, '_', ...
                    band_name, format)));
            else
                Image = getframe(gcf);
                imwrite(Image.cdata, char_check(strcat(...
                    path_check(outDir), 'Histogram_', location, '_', ...
                    measure, '_', band_name, format)));
            end
            close(gcf)
        end
    end
    

%% histogram_initialization
% This function provides all the data and parameters which have to be used
% in the histogram analysis.
function [PAT, HC, bins, measure, band_name, location] = ...
    histogram_initialization(handles, flag)

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
    
    bins = 10;
    if get(handles.low, 'Value') == 1
        bins = 5;
    elseif get(handles.high, 'Value') == 1
        bins = 30;
    elseif get(handles.fd, 'Value') == 1
        bins = 'fd';
    elseif get(handles.scott, 'Value') == 1
        bins = 'scott';
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
    
    if ischar(bins)
        Athena_history_update(strcat("distribution_histogram_analysis(",...
            strcat("'", dataPath, "'"), ',', strcat("'", measure, "'"), ...
            ',', strcat("'", area, "'"), ',', string(band), ',', ...
            string(idx_loc), ',', sub_types_list, ',', ...
            strcat("'", bins, "'"), ',', strcat("'", location, "'"), ...
            ',', strcat("'", band_name, "'"),')'));
        aux_bins_data = [];
        if exist('PAT', 'var')
            aux_bins_data = [aux_bins_data; PAT];
        end
        if exist('HC', 'var')
            aux_bins_data = [aux_bins_data; HC];
        end
        [~, bins] = histcounts(aux_bins_data, 'BinMethod', bins); 
    else
        Athena_history_update(strcat("distribution_histogram_analysis(",...
            strcat("'", dataPath, "'"), ',', strcat("'", measure, "'"), ...
            ',', strcat("'", area, "'"), ',', string(band), ',', ...
            string(idx_loc), ',', sub_types_list, ',', string(bins), ...
            ',', strcat("'", location, "'"), ',', ...
            strcat("'", band_name, "'"),')'));
    end


%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
	d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        dataPath_text_Callback(hObject, eventdata, handles)
    end


%% back_Callback
% Thif function switches to the Statistical Analysis list interface.
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
    close(Athena_hist)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


%% export_Callback
% This function allows to export the results of the histogram analysis on
% an external figure.
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
    if strcmp(get(handles.loc, 'Enable'), 'on') && ...
            strcmp(get(handles.loc, 'Enable'), 'on')
        [PAT, HC, bins, measure, band, location] = ...
            histogram_initialization(handles, flag);
    
        distributions_histogram(HC, PAT, measure, ...
            get(handles.sub_types, 'Data'), location, band, bins)
    end


%% meas_Callback
% This function sets the available frequency bands and spatial subdividions
% with respect to the selected measure.
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
        set(handles.area_text, 'Enable', 'on')
        set(handles.band_text, 'Enable', 'on')   
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
% This function set the available locations with respect to the selected
% spatial subdivision.
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


function medium_Callback(hObject, eventdata, handles)


function low_Callback(hObject, eventdata, handles)

