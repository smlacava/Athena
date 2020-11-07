%% Athena_locsSelecting
% This interface allows to select subset of locations, among the ones
% presented in a list.

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


%% Athena_locsSelecting_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_locsSelecting_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    handles.f = [];
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        locs = varargin{1};
        set(handles.locs, 'String', locs);
        set(handles.locs, 'Max', length(locs), 'Min', 0);
    end
    if nargin >= 5
        current_ind = [1:length(varargin{1})];
        current_ind(varargin{2} == 0) = [];
        set(handles.locs, 'Value', current_ind);
    end
    if nargin >= 6
        if varargin{3} == 1
            set(handles.title, 'String', '     Subject selection')
            set(handles.info, 'String', ...
                'Select the subject you want to show')
            current_ind = varargin{2};
            set(handles.locs, 'Value', current_ind(1));
        else
            chanlocs = varargin{3};
            aux = struct();
            aux.chanlocs = struct();
            idx = zeros(1, length(locs));
            for i = 1:length(locs)
                aux.chanlocs(i).labels = locs{i};
                aux.chanlocs(i).X = chanlocs(i, 1);
                aux.chanlocs(i).Y = chanlocs(i, 2);
                aux.chanlocs(i).Z = chanlocs(i, 3);
            end
            handles.f = show_locations(aux, locs, varargin{2});
        end
    end
    

function varargout = Athena_locsSelecting_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


%% back_callback
% This function closes the interface, returning a 0 to the calling
% function.
function back_Callback(~, ~, handles)
    close(findobj('type', 'figure', 'name', 'Channel locations'))
    assignin('base','Athena_locsSelecting', 0);
    close(Athena_locsSelecting)

    
function axes3_CreateFcn(~, ~, ~)


function locs_Callback(~, ~, ~)


function locs_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% save_Callback
% This function closes the interface, returning the selected locations to
% the calling function.
function save_Callback(~, ~, handles)
        close(findobj('type', 'figure', 'name', 'Channel locations'))
        selectedLocs = get(handles.locs, 'Value');
        %set(handles.output, 'UserData', selectedList);
        assignin('base','Athena_locsSelecting', selectedLocs);
        close(Athena_locsSelecting)
