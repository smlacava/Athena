function varargout = Athena_decompressor(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @Athena_decompressor_OpeningFcn, ...
        'gui_OutputFcn',  @Athena_decompressor_OutputFcn, ...
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


function Athena_decompressor_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    if nargin >= 4
        aux_dataPath = varargin{1};
        set(handles.aux_dataPath, 'String', varargin{1})
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
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
    if nargin == 9
        set(handles.check_dec, 'String', varargin{5})
        if strcmp(varargin{5}, 'folder')
            set(handles.title, 'String', "     Folder decompressor")
            set(handles.intro, 'String', strcat("You can ", ...
                "decompress a compressed file, in .zip, .tar, .tgz, ", ...
                ".gz, or .tar.gz format, which contains a folder, ", ...
                "such as the directory which contains a ", ...
                "dataset (the extracted folder will be saved inside ", ...
                "the same directory of the compressed one, and it ", ...
                "will have the same name"))
            set(handles.check_dec, 'String', varargin{5})
        end
    end

    
function varargout = Athena_decompressor_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function file_Callback(hObject, eventdata, handles)


function file_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

    
function data_search_Callback(hObject, eventdata, handles)
    [d, dp] = uigetfile({'*.*'});
    if d ~= 0
        set(handles.file, 'String', strcat(string(dp), string(d)))
    end

function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_decompressor)
    Athena_utility(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function RUN_Callback(~, eventdata, handles)
    f = waitbar(0,'Initialization', ...
        'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    file = get(handles.file, 'String');
    directory_check = 0;
    if strcmp(get(handles.check_dec, 'String'), 'folder')
        directory_check = 1;
    end
    waitbar(0, f, 'Processing your file')
    decompress(file, directory_check)
    close(f)
    success()
