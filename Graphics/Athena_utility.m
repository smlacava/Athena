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


function back_Callback(hObject, eventdata, handles)
	openAnalysis('back', handles)
    
    
function axes3_CreateFcn(hObject, eventdata, handles)


function file_decompress_Callback(hObject, eventdata, handles)
	openAnalysis('file_decompress', handles)


function signals_divider_Callback(hObject, eventdata, handles)
	openAnalysis('signals_divider', handles)


function folder_decompressor_Callback(hObject, eventdata, handles)
    openAnalysis('folder_decompress', handles)


function signals_extraction_Callback(hObject, eventdata, handles)
    openAnalysis('signals_extraction', handles)

    
function openAnalysis(utility, handles)
    analysis_list = {'folder_decompress', 'file_decompress', ...
        'signals_divider', 'signals_extraction', 'resample', ...
        'common_loc', 'back'};
    analysis_interfaces = {@Athena_decompressor, ...
        @Athena_decompressor, @Athena_dividerPath, @Athena_extract, ...
        @Athena_resample, @Athena_commonLoc, @Athena};
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

function resample_Callback(hObject, eventdata, handles)
	openAnalysis('resample', handles)


function common_loc_Callback(hObject, eventdata, handles)
    openAnalysis('common_loc', handles)
