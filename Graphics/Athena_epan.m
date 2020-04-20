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

    
function Athena_epan_OpeningFcn(hObject, eventdata, handles, varargin)
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
        if not(strcmp(path, 'Static Text')) && ...
                not(strcmp(measure, 'Static Text'))
            dataPath = strcat(path_check(path), measure);
            set(handles.dataPath_text, 'String', dataPath)
        end
    end
    if nargin >= 6
        subs = varargin{3};
        set(handles.aux_sub, 'String', subs)
        sub_list = load_data(subs);
        sub_list = string(sub_list(:, 1))';
        set(handles.Subjects, 'String', sub_list);
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end



function varargout = Athena_epan_OutputFcn(hObject, eventdata, handles) 
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
    dataPath = path_check(dataPath);
    cd(dataPath)
    if exist('auxiliary.txt', 'file')
        auxID = fopen('auxiliary.txt', 'r');
        fseek(auxID, 0, 'bof');
        while ~feof(auxID)
            proper = fgetl(auxID);
            if contains(proper, 'Subjects=')
                subsFile = split(proper,'=');
                subsFile = subsFile{2};
                subs = load_data(subsFile);
                subs = string(subs(:,1))';
            end
            if contains(proper, 'Locations=')
                locations = split(proper, '=');
                locations = locations{2};
                set(handles.aux_loc, 'String', locations)
            end
        end
        fclose(auxID);     
        set(handles.Subjects, 'String', subs);
    end
    cd(auxPath)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

    
function Run_Callback(hObject, eventdata, handles)
    measure = char_check(get(handles.aux_measure, 'String'));
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    if not(exist(dataPath, 'dir'))
    	problem(strcat("Directory ", dataPath, " not found"))
    	return
    end
    cd(char(dataPath))
    
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
    subList = get(handles.Subjects, 'String');
    subName = subList(get(handles.Subjects, 'Value'));
    
    if get(handles.asy_button, 'Value') == 1
        anType = 'asymmetry';
    elseif get(handles.tot_button, 'Value') == 1
        anType = 'total';
    elseif get(handles.glob_button, 'Value') == 1
        anType = 'global';
    else
        anType = 'areas';
    end
    epochs_analysis(dataPath, subName, anType, measure, epochs, bands, loc)    
       

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
    end

    
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, ~] = GUI_transition(handles, 'loc');
    loc = string(get(handles.aux_loc, 'String'));
    if strcmp(loc, 'es. C:\User\Locations.mat')
        loc="Static Text";
    end
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath="Static Text";
    end
    close(Athena_epan)
    Athena_an(dataPath, measure, sub, loc)

    
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
