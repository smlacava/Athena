%% Athena_epan
% This interface allows to execute the visual epoch analysis on a
% previously extracted measure, on the single subjects.


function varargout = Athena_epan(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_epan_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_epan_OutputFcn, ...
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

%% Athena_epan_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_epan_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)

    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
        set(handles.dataPath_text, 'String', path)
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
    end
    if nargin >= 6
        subs = varargin{3};
        set(handles.aux_sub, 'String', subs)
        sub_list = load_data(subs);
        sub_list = string(sub_list(:, 1))';
        set(handles.Subjects, 'String', sub_list);
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    dataPath_text_Callback(hObject, eventdata, handles)


function varargout = Athena_epan_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

%% dataPath_text_Callback
% This function is used when the study directory is changed, in order to
% set the available measures.
function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    subjectsFile = strcat(path_check(limit_path(dataPath, ...
        get(handles.aux_measure, 'String'))), 'Subjects.mat');
    if exist(subjectsFile, 'file')
        set(handles.aux_sub, 'String', subjectsFile)
        try
            sub_info = load(fullfile_check(subjectsFile));
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
        cd(dataPath)
        measures = available_measures(dataPath, 0, 1);
        set(handles.Measures_list, 'String', measures)
        set(handles.Measures_list, 'Value', 1)
        checkS = 0;
        checkL = 0;
        for m = 1:length(measures)
            if checkL == 1 && checkS == 1
                break;
            end
            aux_file = strcat(path_check(dataPath), ...
                path_check(measures(m)), 'auxiliary.txt');
            if exist(aux_file, 'file')
                auxID = fopen(aux_file, 'r');
                fseek(auxID, 0, 'bof');
                while ~feof(auxID)
                    proper = fgetl(auxID);
                    if contains(proper, 'Subjects=')
                        subsFile = split(proper,'=');
                        subsFile = subsFile{2};
                        subs = load_data(subsFile);
                        subs = string(subs(:,1))';
                        checkS = 1;
                    end
                    if contains(proper, 'Locations=')
                        locations = split(proper, '=');
                        locations = locations{2};
                        set(handles.aux_loc, 'String', locations)
                        checkL = 1;
                    end
                end
                fclose(auxID);
                set(handles.Subjects, 'String', subs);
            end
        end
        cd(auxPath)
    end


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% Run_Callback
% This function is called when the Run button is pushed, and it shows the
% measure variation using the set parameters.
function Run_Callback(hObject, eventdata, handles)
    measure = options_list(handles.Measures_list);
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    if not(exist(dataPath, 'dir'))
    	problem(strcat("Directory ", dataPath, " not found"))
    	return
    end
    cd(path_check(strcat(dataPath, measure)))
    [save_check, format] = Athena_save_figures('Save figures', ...
        'Do you want to save the resulting figure?');
    
    if exist('auxiliary.txt', 'file')
        auxID = fopen('auxiliary.txt','r');
        fseek(auxID, 0, 'bof');
    end
    while ~feof(auxID)
        proper = fgetl(auxID);
        if contains(proper, 'epNum=')
            epochs = split(proper, '=');
            epochs = str2double(epochs{2});
        end
        if contains(proper, 'cf=')
            bands = frequency_bands_number(proper);
        end
    end
    fclose(auxID);
    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'

    loc = get(handles.aux_loc, 'String');
    subName = options_list(handles.Subjects);
    
    if get(handles.asy_button, 'Value') == 1
        anType = 'asymmetry';
    elseif get(handles.tot_button, 'Value') == 1
        anType = 'total';
    elseif get(handles.glob_button, 'Value') == 1
        anType = 'global';
    else
        anType = 'areas';
    end
    epochs_analysis(dataPath, subName, anType, measure, epochs, bands, ...
        loc, save_check, format)
    Athena_history_update(strcat('epochs_analysis(', ...
        strcat("'", dataPath, "'"), ',', strcat("'", subName, "'"), ...
            ',', strcat("'", anType, "'"), ',', ...
            strcat("'", measure, "'"), ',', string(epochs), ',', ...
            string(bands), ',', strcat("'", loc, "'"), ',', ...
            string(save_check), ',', strcat("'", format, "'"), ')'));
    
       
%% data_search_callback
% This function is called when the directory-searcher button is pushed, in
% order to open the file searcher and changes the settings with respect to
% the analyzed study directory.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        auxPath = pwd;
        funDir = mfilename('fullpath');
        funDir = split(funDir, 'Graphics');
        cd(char(funDir{1}));
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
                if contains(proper, 'Subjects=')
                    subsFile = split(proper, '=');
                    subsFile = subsFile{2};
                    subs = load_data(subsFile);
                    subs = string(subs(:,1))';
                    set(handles.Subjects, 'String', subs);
                end
                if contains(proper, 'Locations=')
                    locations = split(proper, '=');
                    locations = locations{2};
                    set(handles.aux_loc, 'String', locations)
                end
            end
            fclose(auxID);     
        end
        cd(char(auxPath))
        dataPath_text_Callback(hObject, eventdata, handles)
    end
    

%% back_Callback
% This function switches to the Analysis list interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, ~, sub_types] = GUI_transition(handles, ...
        'loc');
    loc = string(get(handles.aux_loc, 'String'));
    if strcmp(loc, 'es. C:\User\Locations.mat')
        loc="Static Text";
    end
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath="Static Text";
    end
    close(Athena_epan)
    Athena_an(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function aux_loc_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Subjects_Callback(hObject, eventdata, handles)


function Subjects_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Measures_list_Callback(hObject, eventdata, handles)


function Measures_list_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
