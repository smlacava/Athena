function varargout = Athena_reref(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_reref_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_reref_OutputFcn, ...
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


function Athena_reref_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        set(handles.locs, 'String', [varargin{1} 'Average']);
        set(handles.locs, 'Max', length(varargin{1})+1, 'Min', 0);
    end
    

function varargout = Athena_reref_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function back_Callback(~, ~, handles)
    assignin('base','Athena_locsSelecting', 0);
        close(Athena_locsSelecting)

    

function axes3_CreateFcn(~, ~, ~)


function locs_Callback(~, ~, ~)


function locs_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function save_Callback(~, ~, handles)
        selectedLocs = get(handles.locs, 'Value');
        %set(handles.output, 'UserData', selectedList);
        assignin('base','Athena_reref', selectedLocs);
        close(Athena_reref)
