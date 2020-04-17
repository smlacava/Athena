function varargout = Athena_locsSelecting(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_locsSelecting_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_locsSelecting_OutputFcn, ...
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


function Athena_locsSelecting_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        set(handles.locs, 'String', varargin{1});
        set(handles.locs, 'Max', length(varargin{1}), 'Min', 0);
    end
    if nargin >= 5
        current_ind = [1:length(varargin{1})];
        current_ind(varargin{2} == 0) = [];
        set(handles.locs, 'Value', current_ind);
    end
    

function varargout = Athena_locsSelecting_OutputFcn(~, ~, handles) 
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
        assignin('base','Athena_locsSelecting', selectedLocs);
        close(Athena_locsSelecting)
