%% Athena_indcorr
% This interface allows to execute a correlation analysis between a
% measure, chosing the related parameters, and an external index or
% measure, for a group of subjects.


function varargout = Athena_indcorr(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_indcorr_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_indcorr_OutputFcn, ...
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


%% Athena_indcorr_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_indcorr_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
        if not(strcmp(path, "Static Text"))
            set(handles.dataPath_text,'String', path)
        end
        set_measures(path, handles);
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        sub_types = varargin{5};
        set(handles.sub_types, 'Data', sub_types)
        set(handles.PAT, 'String', sub_types{2})
        set(handles.HC, 'String', sub_types{1})
    end
    dataPath_text_Callback(hObject, eventdata, handles)

 
function varargout = Athena_indcorr_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% dataPath_text_Callback
% This function is called when the dataPath is modified, in order to
% refresh the interface, and to set the available measures.
function dataPath_text_Callback(hObject, eventdata, handles)
    set_handles(hObject, eventdata, handles)
    set_measures(get(handles.dataPath_text, 'String'), handles);


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% Run_Callback
% This function is used when the Run button is pushed, and it executes the
% correlation analysis between a measure and the external data, using the
% selected parameters
function Run_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Correlations'
    
    save_check = 0;
    if strcmpi(user_decision(...
            'Do you want to save the resulting tables?', 'U Test'), 'yes')
        save_check = 1;
    end
    [save_check_fig, format] = Athena_save_figures();
    
    Ind = get(handles.ind_text, 'String');
    if not(exist(Ind, 'file'))
        problem(strcat("File ", Ind, " not found"))
        return
    end
    Index = load_data(Ind);
    if size(Index, 1) < size(Index, 2)
        Index = Index';
    end
    Index = Index(:, end);
    
    measure = get(handles.aux_measure, 'String');
    [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, nLoc, ...
        nBands] = correlation_setting(handles);
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    corrPath = create_directory(dataPath, 'StatAn');
    corrPath = create_directory(corrPath, 'Data');
    index_correlation(data, sub_list, bands_names, measure, Index, ...
        alpha, bg_color, locs, P, RHO, nLoc, nBands, save_check, ...
        dataPath, save_check_fig, format)
    
    an_selected = [get(handles.asy_button, 'Value'), ...
        get(handles.tot_button, 'Value'), ...
        get(handles.glob_button, 'Value'), ...
        get(handles.areas_button, 'Value')];
    an_paths = {'Asymmetry', 'Total', 'Global', 'Areas'};
    analysis = an_paths(an_selected == 1);
    sub_types = get(handles.sub_types, 'Data');
    Athena_history_update(strcat("[data, sub_list, alpha, bg_color, ", ...
        "locs, bands_names, P, RHO, nLoc, nBands, analysis, ", ...
        "sub_group] = correlation_setting(", ...
        strcat("'", get(handles.aux_dataPath, 'String'), "'"), ',', ...
        strcat("'", get(handles.aux_measure, 'String'), "'"), ',', ...
        string(get(handles.maxCons, 'Value')), ',', ...
        strcat("'", analysis, "'"), ',', ...
        strcat("{'", sub_types{1}, "','", sub_types{2}, "'}"), ',', ...
        string(get(handles.HC, 'Value')), ',', ...
        string(get(handles.PAT, 'Value')), ',', ...
        strcat("'", get(handles.aux_sub, 'String'), "'"), ')'))
    Athena_history_update(strcat("index_correlation(data, sub_list, ", ...
        'bands_names,', strcat("'", measure, "'"), ',', ...
        strcat("'", Ind, "'"), ...
        ', alpha, bg_color, locs, P, RHO, nLoc, nBands,', ...
        string(save_check), ',', strcat("'", corrPath, "'"), ',', ...
        string(save_check_fig), ',', strcat("'", format, "'"), ')'));
    

%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        set_handles(hObject, eventdata, handles)
    end


function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% back_Callback
% This function switches to the Statistical Analysis list interface.
function back_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_indcorr)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function aux_loc_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function ind_text_Callback(hObject, eventdata, handles)


function ind_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% ind_search_Callback
% This function allows to search the external index's file through the file
% explorer.
function ind_search_Callback(hObject, eventdata, handles)
    [i,ip] = uigetfile;
    if i ~= 0
        set(handles.ind_text, 'String', strcat(string(ip), string(i)))
    end

    
%% set_handles
% This function updates the interface based on the used subjects list file.
function set_handles(hObject, eventdata, handles)
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
                set(handles.PAT, 'String', sub_types{2})
                set(handles.HC, 'String', sub_types{1})
            end
        catch
        end
    end
    

%% set_measures
% This function sets the available measures with respect to the selected
% data directory.
function set_measures(path, handles)
    measures = available_measures(path, 1);
    set(handles.meas, 'String', measures);


%% meas_Callback
% This function updates the interface with respect to the selected measure.
function meas_Callback(hObject, eventdata, handles)
    set_handles(hObject, eventdata, handles)
  

function popupmenu10_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
