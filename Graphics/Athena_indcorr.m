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

    
function Athena_indcorr_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
        if not(strcmp(path, "Static Text")) && ...
                not(strcmp(measure, "Static Text"))
            dataPath = strcat(path_check(path), measure);
            set(handles.dataPath_text,'String', dataPath)
        end
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    set_handles(hObject, eventdata, handles)


    
function varargout = Athena_indcorr_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    set_handles(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Correlations'
    
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
    index_correlation(data, sub_list, bands_names, measure, Index, ...
        alpha, bg_color, locs, P, RHO, nLoc, nBands)
    
   
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


function back_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_indcorr)
    Athena_statistics(dataPath, measure, sub, loc)

    
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


function ind_search_Callback(hObject, eventdata, handles)
    [i,ip] = uigetfile;
    if i ~= 0
        set(handles.ind_text, 'String', strcat(string(ip), string(i)))
    end
    
function set_handles(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    if exist(dataPath, 'dir')
        [imp_analysis, imp_subjects] = impossible_analysis(dataPath);
        subjects_list = {'PAT.mat', 'HC.mat'};
        s_hand = {handles.PAT, handles.HC};
        analysis_list = {'Total', 'Global', 'Asymmetry', 'Areas'};
        a_hand = {handles.tot_button, handles.glob_button, ...
            handles.asy_button, handles.areas_button};
    
        imp_a = length(imp_analysis);
        if imp_a ~= 0
            n_an = length(a_hand);
            for i = 1:n_an
                for j = 1:imp_a
                    if strcmp(imp_analysis{j}, analysis_list{i})
                        set(a_hand{i}, 'Enable', 'off')
                    end
                end
            end
        end
    
        imp_s = length(imp_subjects);
        if imp_s ~= 0
            n_sub = length(s_hand);
            for i = 1:n_sub
                for j = 1:imp_s
                    if strcmp(imp_subjects{j}, subjects_list{i})
                        set(s_hand{i}, 'Enable', 'off')
                    end
                end
            end
        end
    end 
    
    
