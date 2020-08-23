function varargout = Athena(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_OutputFcn, ...
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


function Athena_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    try
        funDir = '';
        auxDir = which('Athena.m');
        auxDir = split(auxDir, filesep);
        for i = 1:length(auxDir)-1
            funDir = strcat(funDir, auxDir{i}, filesep);
        end
        addpath(funDir)
        cd(funDir)
    catch
        funDir = '';
    end
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    [y, ~] = imread(strcat(funDir, 'docs', filesep, 'utility.png'));
    Im2 = imresize(y, [35 35]);
    set(handles.Utility, 'CData', Im2)
    set(handles.guided, 'Tooltip', sprintf(strcat(...
        'The Guided mode allows the you to interact with every \n', ...
        'step, and to repeat every step as much times as wished')));
    set(handles.batch, 'Tooltip', sprintf(strcat(...
        'The Batch mode allows you to automatically execute all the\n', ...
        'previously decided steps of the study by inserting a text\n', ...
        'file, as the one you can find in the toolbox folder or the\n', ...
        'one generated after every study')));
    set(handles.display, 'Tooltip', sprintf(strcat(...
        'The Display mode allows to show all the signals, to select\n', ...
        'the wished locations, to filter your signals and to\n', ...
        'extract and save a time window for each one')));
    set(handles.tf_analysis, 'Tooltip', sprintf(strcat(...
        'The TF mode allows to execute the time-frequency analysis\n', ...
        'on all the signals, selecting the wished location, the\n', ...
        'frequency band and the time window to analyze')));
    set(handles.Freq_button, 'Tooltip', sprintf(strcat(...
        'The Spectrum mode allows to analyze the power spectra of\n', ...
        'your signals, selecting the wished location, the frequency\n', ...
        'band and the time window to analyze')));
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Athena');
    funDir = strcat(funDir{1}, filesep, 'Athena');
    cd(char(funDir));
    addpath 'Graphics'
    addpath 'Auxiliary'
    addpath 'Measures'
    addpath 'Correlations'
    addpath 'Statistical Analysis'
    addpath 'Batch'
    addpath 'Classification'
    addpath 'Epochs Analysis'
    addpath 'Epochs Management'
    addpath 'Loaders'
    addpath 'Network Metrics'
    savepath
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

    
function varargout = Athena_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function back_Callback(~, ~, ~)
    close(Athena)
    
    
function utility_Callback(~, ~, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena)
    Athena_utility(dataPath, measure, sub, loc)
    
function axes3_CreateFcn(~, ~, ~)


function guided_Callback(~, ~, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena)
    Athena_guided(dataPath, measure, sub, loc)
    
    
function tf_analysis_Callback(~, ~, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena)
    Athena_tfPath(dataPath, measure, sub, loc)

    
function batch_Callback(hObject, eventdata, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena)
    Athena_batch(dataPath, measure, sub, loc)
    
    
function spectrum_Callback(hObject, eventdata, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena)
    Athena_freqPath(dataPath, measure, sub, loc)
    
    
function display_Callback(hObject, eventdata, handles)
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena)
    Athena_sigPath(dataPath, measure, sub, loc)