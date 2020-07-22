function varargout = Athena_epmean(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_epmean_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_epmean_OutputFcn, ...
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


function Athena_epmean_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    check_types = 0;
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
        if not(strcmp(path, 'Static Text')) && ...
                not(strcmp(measure, 'Static Text'))
            dataPath = strcat(path_check(path), measure);
            set(handles.dataPath_text, 'String', dataPath);
        end
    end
    if nargin >= 6
        aux_sub = varargin{3};
        if not(strcmp(aux_sub, 'Static Text'))
            set(handles.subjectsFile, 'String', aux_sub)
        elseif exist(strcat(path_check(path), 'Subjects.mat'), 'file')
            set(handles.subjectsFile, 'String', ...
                strcat(path_check(path), 'Subjects.mat'))            
        end
        try
            sub_info = load(get(handles.subjectsFile, 'String'));
            aux_sub_info = fields(sub_info);
            eval(strcat("sub_info = sub_info.", aux_sub_info{1}, ";"));
            sub_types = categories(categorical(sub_info(:, end)));
            if length(sub_types) == 2
                set(handles.sub_types, 'Data', sub_types)
                check_types = 1;
            end
        catch
        end
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8 && check_types == 0
        set(handles.sub_types, 'Data', varargin{5})
    end
        

function varargout = Athena_epmean_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function sub_text_Callback(hObject, eventdata, handles)


function sub_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    if not(exist(dataPath, 'dir'))
    	problem(strcat("Directory ", dataPath, " not found"))
    	return
    end
        
    EMflag = 0;
    cd(dataPath)
    if exist('auxiliary.txt', 'file')
        auxID = fopen('auxiliary.txt', 'a+');
    elseif exist(strcat(dataPath, 'auxiliary.txt'), 'file')
        auxID = fopen(strcat(dataPath, 'auxiliary.txt'), 'a+');
    end
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        proper = fgetl(auxID);
        if contains(proper, 'Measures') || contains(proper, 'measures')
            measure = split(proper, '=');
            measure = measure{2};
            type = measure;
        end
        if contains(proper, 'Epmean')
            EMflag = 1;
            position = ftell(auxID);
        end
    end
    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Epochs Management'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    sub = get(handles.subjectsFile, 'String');
    if not(exist(sub, 'file'))
    	problem(strcat("File ", sub, " not found"))
    	return
    else
        subjects = load_data(sub);
        save(strcat(path_check(get(handles.aux_dataPath, 'String')), ...
            'Subjects.mat'), 'subjects')
    end
    if not(exist('type', 'var'))
        aux_type = split(dataPath, filesep);
        if not(isempty(aux_type{end}))
            type = aux_type{end};
        else
            type = aux_type{end-1};
        end
    end
        
    [locs, sub_types] = epmean_and_manage(dataPath, type, sub);
    Athena_history_update(strcat('[locs, sub_types] = connectivity(', ...
            strcat("'", dataPath, "'"), ",", strcat("'", type, "'"), ...
            ',', strcat("'", sub, "'"), ')'));
    set(handles.sub_types, 'Data', sub_types)
    if not(isempty(locs))
        set(handles.aux_loc, 'String', locs)
    end
    
    management_update_file(dataPath, locs, sub);
    success();

    
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end


function next_Callback(~, ~, handles)
    [dataPath, measure, ~, loc, sub_types] = GUI_transition(handles, 'sub');
    sub = get(handles.subjectsFile, 'String');
    if strcmp('es. C:\User\Sub.mat', sub)
        sub = "Static Text";
    end
    close(Athena_epmean)
    Athena_an(dataPath, measure, sub, loc, sub_types)


function back_Callback(hObject, eventdata, handles)
    meaext_Callback(hObject, eventdata, handles)


function axes3_CreateFcn(hObject, eventdata, handles)


function subjectsFile_Callback(~, eventdata, handles)


function subjectsFile_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function sub_search_Callback(~, eventdata, handles)
    [s,sp] = uigetfile;
    if s ~= 0
        set(handles.subjectsFile, 'String', strcat(string(sp), string(s)))
    end


function meaext_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, ~, loc, types] = GUI_transition(handles, 'sub');
    sub = get(handles.subjectsFile, 'String');
    if strcmp('es. C:\User\Sub.mat', sub)
        sub = "Static Text";
    end
    close(Athena_epmean)
    Athena_guided(dataPath, measure, sub, loc, types)


function subMaking_Callback(~, ~, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, ~, loc] = GUI_transition(handles, 'sub');
    sub = string(get(handles.subjectsFile, 'String'));
    Athena_submaking(dataPath, measure, sub, loc)
    close(Athena_epmean)
