function varargout = Athena_params(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_params_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_params_OutputFcn, ...
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

    
function Athena_params_OpeningFcn(hObject, eventdata, handles, ...
    varargin)
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
        info = "";
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        cases = define_cases(dataPath);
        [data, fs, locs] = load_data(strcat(dataPath, cases(1).name));
        if not(isempty(fs))
            set(handles.fs_text, 'String', string(fs));
            info = strcat("Sampling frequency detected: the signal", ...
                " has a time window of ", string(length(data)/fs), " s \n");
        end
        if not(isempty(locs))
            info = strcat(info, "Locations detected: the locations", ...
                " list will be saved in a file Locations.mat");
            locPath = strcat(dataPath, 'Locations.mat');
            save(locPath, 'locs');
            set(handles.aux_loc, 'String', locPath);
        end
        set(handles.TotTime, 'String', info);
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
        set(handles.Title, 'String', strcat("     Step 1: ", measure, ...
            " extraction"))
        if strcmp(measure, "PSDr")
            set(handles.totBand, 'Visible', 'on')
            set(handles.totBand_text, 'Visible', 'on')
            set(handles.totBand_Hz, 'Visible', 'on')
        end  
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        if not(strcmp(varargin{4}, "Static Text"))
            set(handles.aux_loc, 'String', varargin{4})
        end
    end

    
function varargout = Athena_params_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function fs_text_Callback(hObject, eventdata, handles)
    dataPath = get(handles.aux_dataPath, 'String');
    cases = define_cases(dataPath);
    [data, fs_old] = load_data(strcat(dataPath, cases(1).name));
    fs = str2double(get(handles.fs_text, 'String'));
    TotTime = "T";
    if not(isempty(fs_old))
        if fs < fs_old
            set(handles.fs_text, 'String', string(fs));
            set(handles.fs_res, 'String', 'resampling!');
        elseif fs > fs_old
            problem("The fs cannot be higher than the fs of the data");
            set(handles.fs_text, 'String', string(fs_old));
            return;
        else
            set(handles.fs_res, 'String', '');
        end
        TotTime = "Sampling frequency detected: t";
        fs = fs_old;
    end
    [epNum, epTime, ~] = automatic_parameters(handles, "fs");
    set(handles.epNum_text, 'String', epNum)
    set(handles.epTime_text, 'String', epTime)
    TotTime = strcat(TotTime, "he signal has a time window of ", ...
        string(length(data)/fs), " s ");
    set(handles.TotTime, 'String', TotTime);

    
    
function fs_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function cf_text_Callback(hObject, eventdata, handles)
    [~, ~, totBand] = automatic_parameters(handles, "cf");
    set(handles.totBand_text, 'String', totBand)

function cf_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function epNum_text_Callback(hObject, eventdata, handles)
    [~, epTime, ~] = automatic_parameters(handles, "epNum");
    set(handles.epTime_text, 'String', epTime)

function epNum_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function epTime_text_Callback(hObject, eventdata, handles)
    [~, ~, ~] = automatic_parameters(handles, "epTime");

function epTime_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function tStart_text_Callback(hObject, eventdata, handles)
    [epNum, epTime, ~] = automatic_parameters(handles, "tStart");
    set(handles.epNum_text, 'String', epNum)
    set(handles.epTime_text, 'String', epTime)

function tStart_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function totBand_text_Callback(hObject, eventdata, handles)


function totBand_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(hObject, eventdata, handles)
    dataPath = char_check(get(handles.aux_dataPath, 'String'));
    dataPath = path_check(dataPath);

    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Measures'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    fs = str2double(get(handles.fs_text, 'String'));
    cf = str2double(split(get(handles.cf_text, 'String'), ' '))';
    epNum = str2double(get(handles.epNum_text, 'String'));
    epTime = str2double(get(handles.epTime_text, 'String'));
    tStart = str2double(get(handles.tStart_text, 'String'));
    totBand = str2double(split(get(handles.totBand_text, 'String'), ' '))';
    measure = string(get(handles.aux_measure, 'String'));
    
    [type, connCheck] = type_check(measure);
    
    if strcmp(measure, "PSDr")
        PSDr(fs, cf, epNum, epTime, dataPath, tStart, totBand)
    elseif connCheck == 1
        connectivity(fs, cf, epNum, epTime, dataPath, tStart, measure)
    else
        FOOOFer(fs, cf, epNum, epTime, dataPath, tStart, type)
    end
    
    dataPathM = char(strcat(dataPath, ...
        char_check(get(handles.aux_measure, 'String'))));
    dataPathM = path_check(dataPathM);   
    cd(dataPathM);
            
    auxID = fopen('auxiliary.txt', 'w');
    fprintf(auxID, 'dataPath=%s', dataPath);
    fprintf(auxID, '\nfs=%d', fs);
    fprintf(auxID, '\ncf=');
    for i = 1:length(cf)
        fprintf(auxID, '%d ',cf(i));
    end
    fprintf(auxID, '\nepNum=%d', epNum);
    fprintf(auxID, '\nepTime=%d', epTime);
    fprintf(auxID, '\ntStart=%d', tStart);
    if strcmp(measure, "PSDr")
        fprintf(auxID, '\ntotBand=%d %d', totBand(1), totBand(2));
    end
    fprintf(auxID, '\ntype=%s', type);
    fprintf(auxID, '\nmeasure=%s', measure);
    fprintf(auxID, '\nconnCheck=%d', connCheck);
    fclose(auxID);
    addpath(dataPathM);
    success();


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_params)
    Athena_guided(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)


function next_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_params)
    Athena_epmean(dataPath, measure, sub, loc)
    
