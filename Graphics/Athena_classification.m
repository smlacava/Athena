function varargout = Athena_classification(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_classification_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_classification_OutputFcn, ...
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

    
function Athena_classification_OpeningFcn(hObject, eventdata, handles, ...
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
        set(handles.aux_dataPath, 'String', varargin{1})
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

    
function varargout = Athena_classification_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function repetitions_text_Callback(hObject, eventdata, handles)
    
    
function repetitions_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function train_text_Callback(hObject, eventdata, handles)


function train_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function trees_text_Callback(hObject, eventdata, handles)


function trees_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function bagging_text_Callback(hObject, eventdata, handles)


function bagging_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function subspace_text_Callback(hObject, eventdata, handles)


function subspace_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function pruning_text_Callback(hObject, eventdata, handles)


function pruning_text_CreateFcn(hObject, eventdata, handles)
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
    
    if get(handles.default_parameters, 'Value') == 1
        statistics = classification(dataPath, 0.8, 3, [], [], [], 1000);
    else
        repetitions = str2double(get(handles.repetitions_text, 'String'));
        n_train = str2double(get(handles.train_text, 'String'));
        trees = str2double(get(handles.trees_text, 'String'));
        bagging = str2double(get(handles.bagging_text, 'String'));
        random_subspace = str2double(get(handles.subspace_text, 'String'));
        pruning = get(handles.yes_button, 'Value');
    
        if pruning == 0
            pruning = [];
        end
        if bagging == 0
            bagging = [];
        end
        if random_subspace == 0
            random_subspace = [];
        end
        if trees == 0
            trees = [];
        end
        if n_train == 0
            n_train = 0.8;
        end
        if repetitions == 0
            repetitions = 1;
        end
    
        statistics = classification(dataPath, n_train, trees, bagging, ...
            random_subspace, pruning, repetitions);
    end
    resultDir = strcat(path_check(dataPath), 'Classification');
    if not(exist(resultDir, 'dir'))
        mkdir(resultDir);
    end
    save(strcat(path_check(resultDir), 'Statistics.mat'), 'statistics')
    success();


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_classification)
    Athena_mergsig(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)


function yes_button_Callback(hObject, eventdata, handles)


function no_button_Callback(hObject, eventdata, handles)


function default_parameters_Callback(hObject, eventdata, handles)
    def_par = get(handles.default_parameters, 'Value');
    values = {'on', 'off'};
    value = values{def_par+1};
    
    set(handles.yes_button, 'Enable', value)
    set(handles.no_button, 'Enable', value)
    set(handles.repetitions_text, 'Enable', value)
    set(handles.train_text, 'Enable', value)
    set(handles.trees_text, 'Enable', value)
    set(handles.bagging_text, 'Enable', value)
    set(handles.subspace_text, 'Enable', value)