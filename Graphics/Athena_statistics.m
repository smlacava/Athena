%% Athena_statistics
% This interface allows to select the statistical analysis from the list of
% the currently available ones.


function varargout = Athena_statistics(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_statistics_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_statistics_OutputFcn, ...
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


%% Athena_statistics_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_statistics_OpeningFcn(hObject, eventdata, handles, varargin)
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
    if nargin >= 7
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
    

function varargout = Athena_statistics_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% back_Callback
% This function switches to the Analysis list interface.
function back_Callback(hObject, eventdata, handles)
	openAnalysis('back', handles)
    
    
function axes3_CreateFcn(hObject, eventdata, handles)


%% Distr_Callback
% This function switches to the Distribution Analysis interface.
function Distr_Callback(hObject, eventdata, handles)
	openAnalysis('distributions', handles)


%% MeasCorr_Callback
% This function switches to the Measures Correlation Analysis interface.
function MeasCorr_Callback(hObject, eventdata, handles)
   openAnalysis('measures_correlation', handles)


%% utest_Callback
% This function switches to the U-Test Analysis interface.
function utest_Callback(hObject, eventdata, handles)
	openAnalysis('utest', handles)


%% IndCorr_Callback
% This function switches to the Index Correlation Analysis interface.
function IndCorr_Callback(hObject, eventdata, handles)
    openAnalysis('index_correlation', handles)


%% Hist_Callback
% This function switches to the Histogram Analysis interface.
function Hist_Callback(hObject, eventdata, handles)
    openAnalysis('histogram', handles)


%% openAnalysis
% This function is used to switch the interface with respect to the
% pushed button.
function openAnalysis(analysis, handles)
    analysis_list = {'histogram', 'utest', 'index_correlation', ...
        'measures_correlation', 'distributions', ...
        'descriptive_statistics', 'back'};
    analysis_interfaces = {@Athena_hist, @Athena_utest, ...
        @Athena_indcorr, @Athena_meascorr, @Athena_distr, ...
        @Athena_descriptive_statistics, @Athena_an};
    to_check = {'utest', 'index_correlation', 'measures_correlation'};
    if sum(strcmp(to_check, analysis))
        if not(search_ext_toolbox(...
                'Statistics and Machine Learning Toolbox'))
            return
        end
    end
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_statistics)
    an_handle = analysis_interfaces{strcmp(analysis_list, analysis)};
    an_handle(dataPath, measure, sub, loc, sub_types)


%% DescStat_Callback
% This function switches to the Descriptive Statistical Analysis interface.
function DescStat_Callback(hObject, eventdata, handles)
    openAnalysis('descriptive_statistics', handles)