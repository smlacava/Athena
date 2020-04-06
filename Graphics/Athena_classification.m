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
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin == 8
        if strcmp(varargin{5}, 'nn')
            set(handles.DTclassifier, 'Visible', 'off')
            set(handles.pruning, 'Visible', 'off')
            set(handles.FResample, 'String', 'Validation fraction')
            set(handles.fraction_text, 'String', '0.1')
            set(handles.FResample, 'Tooltip', ...
                'This is the fraction of dataset used for the validation')
            set(handles.nTrees, 'String', 'Hidden layers')
            set(handles.nTrees, 'Tooltip', ...
                'This is the number of hidden layers')
            set(handles.yes_button, 'Visible', 'off')
            set(handles.no_button, 'Visible', 'off')
            set(handles.Title, 'String', ' Neural Network Classification')
        end
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


function nodes_text_Callback(hObject, eventdata, handles)
    set(handles.aux_trees, 'String', get(handles.nodes_text, 'String'))

    
function nodes_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function fraction_text_Callback(hObject, eventdata, handles)
    set(handles.aux_resample, 'String', get(handles.fraction_text, ...
        'String'))

    
function fraction_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function pca_value_Callback(hObject, eventdata, handles)


function pca_value_CreateFcn(hObject, eventdata, handles)
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
        if strcmpi(get(handles.DTclassifier, 'Visible'), 'on')
            statistics = random_forest(dataPath, 7, 0.5, 'on', 1000, 1, ...
                100, 'split', 0.8);
        else
            statistics = neural_network(data, 10, 0.2, 1, 10, 1, 100, ...
                'split', 0.5, 0.7);
        end
    else
        repetitions = str2double(get(handles.repetitions_text, 'String'));
        n_train = str2double(get(handles.train_text, 'String'));
        nodes = str2double(get(handles.nodes_text, 'String'));
        fraction = str2double(get(handles.fraction_text, 'String'));
        pruning = get(handles.yes_button, 'Value');
        pca_value = str2double(get(handles.pca_value, 'String'));
        if get(handles.TTS_button, 'Value') == 1
            eval_method = 'split';
        else
            eval_method = 'leaveoneout';
        end
    
        if pruning == 0
            pruning = [];
        end
        if fraction == 0
            fraction = [];
        end
        if nodes == 0
            nodes = [];
        end
        if n_train == 0
            n_train = 0.8;
        end
        if repetitions == 0
            repetitions = 1;
        end
        if pca_value < 1 && pca_value > 0
            pca_value = pca_value*100;
        elseif not(pca_value > 0  && pca_value <= 100)
            problem('The PCA value must be a value between 0 and 100');
            return
        end
        
        if strcmpi(get(handles.DTclassifier, 'Visible'), 'on')
            statistics = random_forest(dataPath, nodes, fraction, ...
                pruning, repetitions, 1, pca_value, eval_method, n_train);
        else
            if fraction+n_train >= 1
                problem(char_check(strcat("The sum between validation", ...
                    " fraction and testing fraction cannot be higher ", ...
                    "than 1")))
                return
            end                
            statistics = neural_network(dataPath, nodes, fraction, 1, ...
                repetitions, 1, pca_value, eval_method, n_train);
        end
    end
    resultDir = strcat(path_check(dataPath), 'Classification');
    if not(exist(resultDir, 'dir'))
        mkdir(resultDir);
    end
    warning('off','all')
    save(strcat(path_check(resultDir), 'Statistics.mat'), 'statistics')
    warning('on','all')
    success();


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_classification)
    Athena_selectClass(dataPath, measure, sub, loc)


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
    set(handles.LOO_button, 'Enable', value)
    set(handles.TTS_button, 'Enable', value)
    set(handles.nodes_text, 'Enable', value)
    set(handles.fraction_text, 'Enable', value)
    set(handles.pca_value, 'Enable', value)


function DTclassifier_Callback(hObject, eventdata, handles)
    dt_par = get(handles.DTclassifier, 'Value')+1;
    values = {'on', 'off'};
    value = values{dt_par};
    t_num = {get(handles.aux_trees, 'String'), "1"};
    r_num = {get(handles.aux_resample, 'String'), "1"};
    
    set(handles.nodes_text, 'String', t_num{dt_par})
    set(handles.fraction_text, 'String', r_num{dt_par})
    set(handles.nodes_text, 'Enable', value)
    set(handles.fraction_text, 'Enable', value)