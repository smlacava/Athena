function varargout = Athena_statan(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_statan_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_statan_OutputFcn, ...
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

    
function Athena_statan_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3, 'Units', 'pixels');
    resizePos = get(handles.axes3, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
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
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        loc = varargin{4};
        if not(strcmp(loc, 'Static Text'))
            set(handles.loc_text, 'String', loc)
        end
    end

    
function varargout = Athena_statan_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
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
            if contains(proper, 'Locations=')
                locations = split(proper, '=');
                locations = locations{2};
                set(handles.loc_text, 'String', locations)
            end
        end
        fclose(auxID);     
    end
    cd(auxPath)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    im = imread('untitled3.png');
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    cd(dataPath)
    EMflag = 0;
    LOCflag = 0;
    if exist('auxiliary.txt', 'file')
        auxID = fopen('auxiliary.txt', 'a+');
    elseif exist(strcat(dataPath, 'auxiliary.txt'), 'file')
        auxID = fopen(strcat(dataPath, 'auxiliary.txt'), 'a+');
    end
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        proper = fgetl(auxID);
        if contains(proper, 'Epmean=')
            EMflag = 1;
        elseif contains(proper, 'Locations=')
            LOCflag = 1;
        elseif contains(proper, 'connCheck=')
            connCheck = split(proper, '=');
            connCheck = str2double(connCheck{2});
        elseif contains(proper, 'measure=')
            measure = split(proper, '=');
            measure = measure{2};
        elseif contains(proper, 'PAT=')
            PAT = split(proper, '=');
            PAT = PAT{2};
        elseif contains(proper, 'HC=')
            HC = split(proper, '=');
            HC = HC{2};
        end
    end
    
    if EMflag == 0
        uiwait(msgbox('Temporal Avarage not computed', 'Error', ...
            'custom', im));
        close(Athena_statan)
        Athena_epmean
        cd(dataPath)
    else    
        funDir = which('Athena.m');
        funDir = split(funDir, 'Athena.m');
        cd(funDir{1});
        addpath 'Statistical Analysis'
        addpath 'Auxiliary'
        addpath 'Graphics'
    
        loc = get(handles.loc_text, 'String');
        if LOCflag == 0
            fprintf(auxID, '\nLocations=%s', loc);
        end
        fclose(auxID);
        minCons_state = get(handles.minCons, 'Value');
        maxCons_state = get(handles.maxCons, 'Value');
    
        if get(handles.asy_button, 'Value') == 1
            anType = 'asymmetry';
        elseif get(handles.tot_button, 'Value') == 1
            anType = 'total';
        elseif get(handles.glob_button, 'Value') == 1
            anType = 'global';
        else
            anType = 'areas';
        end
        if minCons_state == 1
            cons = 0;
        else
            cons = 1;
        end
    
        [P, Psig, locList, data, dataSig]=mult_t_test(PAT, HC, loc, ...
            connCheck, anType, cons);
        
        bands = string();
        for i = 1:size(P, 1)
            bands = [bands; strcat('Band', string(i))];
        end
        bands(1, :) = [];
        bands = cellstr(bands);
        
        if length(size(data)) == 3
            auxData = [];
            for i = 1:size(data, 3)
                auxData = [auxData data(:, :, i)];
            end
            data = auxData;
            clear auxData;
        end
        
        fs1 = figure('Name', 'Data', 'NumberTitle', 'off');
        d = uitable(fs1, 'Data', data, 'Position', [20 20 525 375]);
        fs2 = figure('Name', 'Statistical Analysis - p-value', ...
            'NumberTitle', 'off');
        p = uitable(fs2, 'Data', P, 'Position', [20 20 525 375], ...
            'RowName', bands, 'ColumnName', locList);
        
        if size(Psig, 1) ~= 0 && not(logical(sum(sum(strcmp(Psig, '')))))
            fs3 = figure('Name', ...
                'Statistical Analysis - Significant Results', ...
                'NumberTitle', 'off');
            ps = uitable(fs3, 'Data', cellstr(Psig), 'Position', ...
                [20 20 525 375]);
        end
        
        dataPath = char(dataPath);
        statanDir = limit_path(dataPath, measure);
        statanDir = path_check(statanDir);
        statanDir = strcat(statanDir, 'StatAn');
        statanType = strcat(measure, '_', anType, '.mat');
        if not(exist(statanDir, 'dir'))
            mkdir(statanDir, 'statAn')
        end
        statAnResult = struct();
        statAnResult.Psig = Psig;
        statAnResult.dataSig = dataSig;
        save(strcat(statanDir,statanType), 'statAnResult')
        
        dataPath = string(dataPath);
        cd(dataPath)
    end

    
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


function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function back_Callback(hObject, eventdata, handles)
    [dataPath, measure, sub, ~] = GUI_transition(handles, 'loc');
    loc = string(get(handles.loc_text, 'String'));
    if strcmp(loc, 'es. C:\User\Locations.mat')
        loc = "Static Text";
    end
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_statan)
    Athena_an(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)


function loc_text_Callback(hObject, eventdata, handles)


function loc_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function loc_search_Callback(hObject, eventdata, handles)
    [i, ip] = uigetfile;
    if i ~= 0
        set(handles.loc_text, 'String', strcat(string(ip), string(i)))
    end