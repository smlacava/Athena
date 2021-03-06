%% Athena_selectClass
% This interface allows to select the classifier to use for a
% classification analysis.


function varargout = Athena_selectClass(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_selectClass_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_selectClass_OutputFcn, ...
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


%% Athena_selectClass_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_selectClass_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
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
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    auxPath = pwd;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    cd(auxPath)
    

function varargout = Athena_selectClass_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% back_Callback
% This function switches to the Classification Dataset Creation interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_selectClass)
    Athena_mergsig2(dataPath, measure, sub, loc)
    
    
function axes3_CreateFcn(hObject, eventdata, handles)


%% NeuralNetwork_Callback
% This function switches to the Classification interface, setting the
% neural network as classifier.
function NeuralNetwork_Callback(hObject, eventdata, handles)
    if search_ext_toolbox('Deep Learning Toolbox') == 1
        funDir = mfilename('fullpath');
        funDir = split(funDir, 'Graphics');
        cd(char(funDir{1}));
        addpath 'Auxiliary'
        addpath 'Graphics'
        [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
        close(Athena_selectClass)
        Athena_classification(dataPath, measure, sub, loc, sub_types, 'nn')
    end


%% RandomForest_Callback
% This function switches to the Classification interface, setting the
% random forest as classifier.
function RandomForest_Callback(hObject, eventdata, handles)
    if search_ext_toolbox('Statistics and Machine Learning Toolbox') == 1
        funDir = mfilename('fullpath');
        funDir = split(funDir, 'Graphics');
        cd(char(funDir{1}));
        addpath 'Auxiliary'
        addpath 'Graphics'
        [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
        close(Athena_selectClass)
        Athena_classification(dataPath, measure, sub, loc, sub_types, 'rf')
    end
