function varargout = Athena_meascorr(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_meascorr_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_meascorr_OutputFcn, ...
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


function Athena_meascorr_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage = imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
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
    

    
function varargout = Athena_meascorr_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'


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
    
    [~, sub_list, alpha, bg_color, locs, bands_names, P, RHO, nLoc, ...
        nBands, analysis, sub_group] = correlation_setting(handles);
    
    meas_state = [get(handles.meas1,'Value') get(handles.meas2,'Value')];
    meas_list = {'PSDr', 'PLV', 'PLI', 'AEC', 'AECo'};
    measures = meas_list(meas_state);
    
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    data_name = strcat(dataPath, path_check(measures{1}), ...
        path_check('Epmean'), path_check(char_check(analysis)), ...
        char_check(sub_group));
    try
        xData = load_data(data_name);
    catch
        problem(strcat(measures{1}, " epochs averaging of not computed"));
        return;
    end
    data_name = strcat(dataPath, path_check(measures{2}), ...
    	path_check('Epmean'), path_check(char_check(analysis)), ...
        char_check(sub_group));
    try
        yData = load_data(data_name);
    catch
        problem(strcat(measures{2}, " epochs averaging of not computed"));
        return;
    end
    if size(xData, 1) ~= size(yData, 1)
        problem(strcat("There is a different number of subjects for ", ...
            "the measures (perhaps, a different subjects' file has ", ...
            "been used)"));
        return;
    end
    
    if get(handles.no, 'Value') == 1
        sub_list = [];
    end
    
    measures_correlation(xData, yData, sub_list, bands_names, ...
        measures, alpha, bg_color, locs, P, RHO, nLoc, nBands)    
       

function data_search_Callback(hObject, eventdata, handles)
	d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        auxPath = pwd;
        dataPath = get(handles.dataPath_text, 'String');
        dataPath = path_check(dataPath);
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
                if contains(proper, 'Locations=')
                    locations = split(proper, '=');
                    locations = locations{2};
                    set(handles.loc_text, 'String', locations)
                end
            end
            fclose(auxID);     
        end
        cd(auxPath)
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
    close(Athena_meascorr)
    Athena_an(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)


function meas1_Callback(hObject, eventdata, handles)


function meas1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

    
function meas2_Callback(hObject, eventdata, handles)


function meas2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
