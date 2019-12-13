function varargout = Athena_submaking(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_submaking_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_submaking_OutputFcn, ...
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


function Athena_submaking_OpeningFcn(hObject, ~, handles, varargin)
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
        dataPath = varargin{1};
        set(handles.aux_dataPath, 'String', dataPath)
        cd(char(dataPath))
        cases = define_cases('');
        n = length(cases);
        subs = string(zeros(n, 1));
        for i = 1:n
            aux_s = cases(i).name;
            aux_s = split(aux_s, '.');
            subs(i) = aux_s{1};
        end
        set(handles.subs, 'String', subs);
        set(handles.subs, 'Max', n, 'Min', 0);
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        loc = varargin{4};
        if not(strcmp(loc, "Static Text"))
            set(handles.aux_loc, 'String', loc)
        end
    end
    

function varargout = Athena_submaking_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


function back_Callback(~, ~, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, ~, loc] = GUI_transition(handles);
    sub = string(get(handles.aux_dataPath, 'String'));
    sub = strcat(path_check(sub), 'Subjects.mat');
    Athena_epmean(dataPath, measure, sub, loc)
    close(Athena_submaking)
    

function axes3_CreateFcn(~, ~, ~)


function subs_Callback(~, ~, ~)


function subs_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function save_Callback(~, ~, handles)
    dataPath = get(handles.aux_dataPath, 'String');
    
    if strcmp(dataPath, "es. C:\User\Data")
        problem('Directory not selected');
        
    else
        auxDir = pwd;
        funDir = mfilename('fullpath');
        funDir = split(funDir, 'Graphics');
        cd(char(funDir{1}));
        addpath 'Auxiliary'
        addpath 'Graphics'
    
        subList = get(handles.subs, 'String');
        patList = get(handles.subs, 'Value');
        n = length(subList);
        subjects = [string(subList), string(zeros(n, 1))];
        for i = 1:n
            if sum(patList == i) > 0
                subjects(i, 2) = 1;
            end
        end
        
        dataPath = path_check(char_check(dataPath));
        save(strcat(dataPath, 'Subjects.mat'), 'subjects')
        cd(auxDir)
        success()
    end
