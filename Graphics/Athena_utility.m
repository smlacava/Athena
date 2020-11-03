%% Athena_utility
% This interface allows to select one of the utilities which are available
% in the toolbox.


function varargout = Athena_utility(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_utility_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_utility_OutputFcn, ...
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


%% Athena_utility_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_utility_OpeningFcn(hObject, eventdata, handles, varargin)
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
    

function varargout = Athena_utility_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% back_Callback
% This function switches to the initial interface of the toolbox.
function back_Callback(hObject, eventdata, handles)
	openAnalysis('back', handles)
    
    
function axes3_CreateFcn(hObject, eventdata, handles)


%% file_decompress_Callback
% This utility switches to the File Decompression interface.
function file_decompress_Callback(hObject, eventdata, handles)
	openAnalysis('file_decompress', handles)


%% signals_divider_Callback
% This function switches to the Signals Divider interface.
function signals_divider_Callback(hObject, eventdata, handles)
	openAnalysis('signals_divider', handles)


%% folder_decompressor_Callback
% This function switches to the Archive Decompression interface.
function folder_decompressor_Callback(hObject, eventdata, handles)
    openAnalysis('folder_decompress', handles)


%% signals_extraction_Callback
% This function switches to the Signals Extraction interface.
function signals_extraction_Callback(hObject, eventdata, handles)
    openAnalysis('signals_extraction', handles)


%% openAnalysis
% This function switches to another interface, with respect to the pushed
% button.
function openAnalysis(utility, handles)
    analysis_list = {'folder_decompress', 'file_decompress', ...
        'signals_divider', 'signals_extraction', 'resample', ...
        'common_loc', 'common_subjects', 'history2script', 'back'};
    analysis_interfaces = {@Athena_decompressor, ...
        @Athena_decompressor, @Athena_dividerPath, @Athena_extract, ...
        @Athena_resample, @Athena_commonLoc, @Athena_commonSubjects, ...
        @Athena_history2script, @Athena};
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_utility)
    an_handle = analysis_interfaces{strcmp(analysis_list, utility)};
    if strcmp(utility, 'folder_decompress')
        an_handle(dataPath, measure, sub, loc, sub_types, 'folder')
    elseif strcmp(utility, 'file_decompress')
        an_handle(dataPath, measure, sub, loc, sub_types, 'file')
    else
        an_handle(dataPath, measure, sub, loc, sub_types)
    end


%% resample_Callback
% This function switches to the Signals Resampling interface.
function resample_Callback(hObject, eventdata, handles)
	openAnalysis('resample', handles)


%% common_loc_Callback
% This function switches to the Common Locations Extraction interface.
function common_loc_Callback(hObject, eventdata, handles)
    openAnalysis('common_loc', handles)

    
%% common_subjects_Callback
% This function switches to the Common Subjects Extraction interface.
function common_subjects_Callback(hObject, eventdata, handles)
    openAnalysis('common_subjects', handles)


%% history2script_Callback
% This function switches to the Hitory to Script interface.
function history2script_Callback(hObject, eventdata, handles)
    openAnalysis('history2script', handles)

