%% Athena_mergsig2
% This interface allows to compute the classification dataset, by using the
% selected measures, with the related spatial subdivisions, among the ones
% which have been computed. Furthermore, a Principal Component Analysis
% (PCA) is performed, allowing to choose if apply the related
% transformation to the dataset, as well as the threshold which represents
% the amount of information to reach, automatically selecting the needed
% principal component, starting from the most informative to the less
% informative. Finally, the dataset will be saved as a table, having on the
% first column the label identifying the belonging group of each subject,
% while on the other columns each feature values.


function varargout = Athena_mergsig2(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_mergsig2_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_mergsig2_OutputFcn, ...
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

    
%% Athena_mergsig2_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_mergsig2_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
        if not(strcmp(path, 'Static Text'))
            set(handles.dataPath_text, 'String', path)
        end
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        loc = varargin{4};
        if not(strcmp(loc, 'Static Text'))
            set(handles.aux_loc, 'String', loc)
        end
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    dataPath_text_Callback(hObject, eventdata, handles)
    set(handles.slider, 'Value', 0)
    move_objects(hObject, eventdata, handles)
    set(handles.slider, 'SliderStep', [0, 1])
    set(handles.slider, 'Min', 0)
    set(handles.slider, 'Max', 1)
    set(handles.slider, 'SliderStep', [1, 1000000000000])
    set(handles.slider, 'Value', 1)

    
function varargout = Athena_mergsig2_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;

    
%% dataPath_text_Callback
% This function is called when the dataPath is modified, in order to
% refresh the interface, and to set the available measures.
function dataPath_text_Callback(hObject, eventdata, handles)
	dataPath = get(handles.dataPath_text, 'String');
    if not(exist(dataPath, 'dir')) || strcmpi(dataPath, ...
                get(handles.aux_dataPath, 'String')) == 0
        return;
    end 
    set(handles.aux_dataPath, 'String', dataPath);
    measures = available_measures(dataPath, 1, 1);
    set(handles.measure1, 'String', measures)
    set(handles.measure1, 'Value', 1)
    del_callback(hObject, eventdata, handles, 1);
                

function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Channels1_Callback(hObject, eventdata, handles)


function Global1_Callback(hObject, eventdata, handles)


function Areas1_Callback(hObject, eventdata, handles)


function Asymmetry1_Callback(hObject, eventdata, handles)


%% Run_Callback
% This function is called when the Run button is pushed, in order to
% compute the dataset, to perform the Principal Component Analysis (PCA),
% to choose a threshold to analyze the number of principal components which
% are needed to reach it, and eventually to apply the transformation on the
% dataset, and finally to save it.
function Run_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    if not(exist(dataPath, 'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    
    dataType = 'All';
    anType = {};
    for n = 1:1000
        try
            if strcmpi(eval(strcat("get(handles.add", string(n), ...
                    ",'String')")), 'ADD')
                break;
            end
            anType = [anType, eval(strcat("get(handles.measure", ...
                string(n), ",'String')"))];
            aux_types = {};
            if eval(strcat("get(handles.Areas", string(n), ...
                    ",'Value')")) == 1
                aux_types = [aux_types, 'Areas'];
            end
            if eval(strcat("get(handles.Channels", string(n), ...
                    ",'Value')")) == 1
                aux_types = [aux_types, 'Total'];
            end
            if eval(strcat("get(handles.Global", string(n), ...
                    ",'Value')")) == 1
                aux_types = [aux_types, 'Global'];
            end
            if eval(strcat("get(handles.Asymmetry", string(n), ...
                    ",'Value')")) == 1
                aux_types = [aux_types, 'Asymmetry'];
            end
            anType = [anType, {aux_types}];
        catch
            break;
        end
    end
    
    value = 100;
    data = dataset_creation(dataPath, anType, dataType);
    if size(data, 2) == 1
        problem('There are not enough data parameters')
        return
    end
    [aux_data, pc] = reduce_predictors(data, value);
    answer = user_decision(strcat("The resulting dataset is composed ", ...
        string(size(data, 2)-1), " features. Do you want to apply ", ...
        "the Principal Component Analysis on your data?"), ...
        "Dataset computed");
    if strcmpi(answer, 'yes')
        pcaFLAG = 1;
    else
        pcaFLAG = 0;
    end
    close(pc)
    while strcmpi(answer, 'yes')
        value = value_asking(100, 'PCA value', strcat("Choose the ", ...
            "minimum fraction of the total variance which has to be ", ...
            "maintained"));
        if value < 1 && value > 0
            value = value*100;
        elseif not(value > 0  && value <= 100)
            problem('The PCA value must be a value between 0 and 100');
            continue
        end
        [aux_data, pc] = reduce_predictors(data, value);       
        answer = user_decision(strcat("The resulting dataset is ", ...
            "composed ", string(size(aux_data, 2)-1), " features. Do ", ...
            "you want to compute again the Principal Component ", ...
            "Analysis on your data?"), "Dataset computed");
        close(pc)
    end
    if pcaFLAG == 1 && ...
            strcmpi(user_decision(strcat("Do you want to save the PCA", ...
            " resulting dataset instead of the original one?"), ...
            "Dataset computed"), 'yes')
        data = aux_data;
    end
    if size(data, 2) > 0
        answer = user_decision(strcat("Do you want to see the list of", ...
            " features?"), "Dataset computed");
        if strcmpi(answer, 'yes')
            fs3 = figure('Color', [1 1 1], 'NumberTitle', 'off', ...
                'Name', 'Statistical Analysis - Significant Results');
            ps = uitable(fs3, 'Data', ...
                cellstr(data.Properties.VariableNames(2:end))', ...
                'Position', [20 20 525 375], 'ColumnName', {'Features'});
        end
        save(strcat(path_check(dataPath), 'Classification', filesep, ...
            'Classification_Data.mat'), 'data')
    end
    
    anType_text = '{';
    for i = 1:length(anType)
        if mod(i, 2) == 0
            anType_text = strcat(anType_text, "{");
            for j = 1:length(anType{i})
                if j == length(anType{i})
                    ending = "'},";
                    if i == length(anType)
                        ending = "'}";
                    end
                else
                    ending = "',";
                end
                anType_text = strcat(anType_text, "'", anType{i}{j}, ...
                    ending);
            end
        else
            anType_text = strcat(anType_text, "'", anType{i}, "',");
        end
    end
    anType_text = strcat(anType_text, '}');
    
    Athena_history_update(strcat('data=dataset_creation(', ...
        strcat("'", dataPath, "'"), ',',  anType_text, ')'));
    Athena_history_update(strcat('data=reduce_predictors(data, ', ...
        string(value), ')'));
    success();

    
%% data_search_Callback
% This function is called when the directory-searcher button is pushed, in
% order to open the file searcher and changes the settings with respect to
% the analyzed study directory.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        set(handles.aux_dataPath, 'String', d)
        auxPath = pwd;
        dataPath = get(handles.dataPath_text, 'String');
        dataPath = path_check(dataPath);
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
                if contains(proper, 'Subjects=')
                    subsFile = split(proper, '=');
                    subsFile = subsFile{2};
                    set(handles.aux_sub, 'String', subsFile);
                end
                if contains(proper, 'Locations=')
                    locations = split(proper, '=');
                    locations = locations{2};
                    set(handles.aux_loc, 'String', locations)
                end
            end
            fclose(auxID);     
        end
        cd(auxPath)
        dataPath_text_Callback(hObject, eventdata, handles)
    end
    

%% back_Callback
% This function switches to the Analysis selection interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath="Static Text";
    end
    close(Athena_mergsig2)
    Athena_an(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


function checkbox5_Callback(hObject, eventdata, handles)


function checkbox7_Callback(hObject, eventdata, handles)


%% Classification_Callback
% This function switches to the classification interface.
function Classification_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_mergsig2)
    Athena_selectClass(dataPath, measure, sub, loc, sub_types)


function allData_Callback(hObject, eventdata, handles)


function sigData_Callback(hObject, eventdata, handles)


function checkbox26_Callback(hObject, eventdata, handles)

%% slider_Callback
% This function moves the features related objects with respect to the
% slider position.
function slider_Callback(hObject, eventdata, handles)
    slide = get(handles.slider, 'Max') - get(handles.slider, 'Value');
    if slide == 0.99
        slide = 0;
    end
    move_objects(hObject, eventdata, handles, slide)

    
function slider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

    
%% set_slider
% This function is used to manage the slider parameters when a measure is
% added or removed.
function set_slider(hObject, eventdata, handles, n)
    range = (n-4);
    if range <= 0
        range = 1;
        steps = [1/range, 100000/range];
    else
        steps = [1/range, 10/range];
    end
    set(handles.slider, 'Max', range)
    set(handles.slider, 'SliderStep', steps);
    if n < 5
        set(handles.slider, 'Value', 0.01)
    else
        set(handles.slider, 'Value', 0.001)
    end
    slider_Callback(hObject, eventdata, handles)
    
    
%% move_objects
% This function initialize the position of the lists and options related to
% the measures (if slide is not used as argument), or update their
% positions based on the slider bar position.
function move_objects(hObject, eventdata, handles, slide)
    if nargin < 4
        slide = 0;
    end
    delta = 0.169;
    slide = slide*delta;
    y = 0.933+slide;
    y_opt = 0.927+slide;
    x = ", [0.0174,";
    wh = ",0.2882, 0.1685])";
    x_opt = ", [0.3346,";
    wh_opt = ",0.6112, 0.2079])";
    for i = 1:100
        try
            aux_delta = i*delta;
            eval(strcat("set(handles.measure", string(i), ",'Position'",...
                x, string(y-aux_delta), wh));
            eval(strcat("set(handles.options", string(i), ",'Position'",...
                x_opt, string(y_opt-aux_delta), wh_opt));
        catch
            break;
        end
    end

    
%% set_measures
% This function sets the measure available and not already selected in the
% not already selected list, and returns the list to the caller.
function measures = set_measures(hObject, eventdata, handles, n)
    try
        if n > 0
            eval(strcat("get(handles.measure", string(n), ",'String');"));
        end
    catch
        return;
    end
    dataPath = get(handles.dataPath_text, 'String');
    measures = available_measures(dataPath, 1, 1);
    n = n+1;
    for i = 1:n-1
        aux_measure = eval(strcat("get(handles.measure", string(n-i), ...
            ",'String');"));
        measures(find(strcmpi(measures, aux_measure))) = [];
    end
    if not(isempty(measures))
        eval(strcat("set(handles.measure", string(n), ...
            ",'String', measures)"));
    end

    
%% add_callback
% This function updates the interface if a measure (n) is added or removed 
% (in this case, the del_callback function is called).
function add_callback(hObject, eventdata, handles, n)
    n = str2double(n);
    check = eval(strcat("get(handles.add", string(n), ",'String')"));
    if strcmpi(check, 'ADD')
        set_slider(hObject, eventdata, handles, n)
        eval(strcat("set(handles.add", string(n), ",'String', 'DEL')"))
        eval(strcat("set(handles.measure", string(n), ",'Enable', 'off')"))
        aux_measures = eval(strcat("get(handles.measure", string(n), ...
            ",'String');"));
        aux_idx = eval(strcat("get(handles.measure", string(n), ...
            ",'Value');"));
        if iscell(aux_measures)
            aux = aux_measures{aux_idx};
        else
            aux = aux_measures;
        end
        eval(strcat("set(handles.measure", string(n), ",'Value',1)"))
        eval(strcat("set(handles.measure", string(n), ",'String','", ...
            aux, "')"))
        measures = set_measures(hObject, eventdata, handles, n);
        if isempty(measures)
            return;
        end
        try
            idx = string(n+1);
            visible = strcat(idx, ",'Visible', 'on')");
            enable = strcat(idx, ",'Enable', 'on')");
            eval(strcat("set(handles.measure", visible))
            eval(strcat("set(handles.options", visible))
            eval(strcat("set(handles.add", visible))
            eval(strcat("set(handles.measure", enable))
            eval(strcat("set(handles.Areas", idx, ", 'Value',0)"))
            eval(strcat("set(handles.Channels", idx, ", 'Value', 0)"))
            eval(strcat("set(handles.Global", idx, ", 'Value', 0)"))
            eval(strcat("set(handles.Asymmetry", idx, ", 'Value', 0)"))
        catch
        end
    else
        set_slider(hObject, eventdata, handles, n-1)
        del_callback(hObject, eventdata, handles, n)
    end

    
%% del_callback
% This function updates the interface when a measure (n) is removed.
function del_callback(hObject, eventdata, handles, n)
    Ntot = 1000;
    for i = n+1:Ntot
        try
            if strcmpi('on', eval(strcat("get(handles.add", string(i), ...
                    ", 'Visible');")))
                visible = strcat(string(i), ",'Visible', 'on')");
                add_str = eval(strcat("get(handles.add", string(i), ...
                    ", 'String');"));
                eval(strcat("set(handles.measure", visible))
                eval(strcat("set(handles.options", visible))
                eval(strcat("set(handles.add", visible))
                eval(strcat("set(handles.Areas", string(i-1), ...
                    ", 'Value', get(handles.Areas", string(i), ...
                    ", 'Value'))"))
                eval(strcat("set(handles.Channels", string(i-1), ...
                    ", 'Value', get(handles.Channels", string(i), ...
                    ", 'Value'))"))
                eval(strcat("set(handles.Global", string(i-1), ...
                    ", 'Value', get(handles.Global", string(i), ...
                    ", 'Value'))"))
                eval(strcat("set(handles.Asymmetry", string(i-1), ...
                    ", 'Value', get(handles.Asymmetry", string(i), ...
                    ", 'Value'))"))
                if strcmpi(add_str, 'ADD')
                    visible = strcat(string(i), ",'Visible', 'off')");
                    enable = strcat(string(i-1), ",'Enable', 'on')");
                    eval(strcat("set(handles.measure", visible))
                    eval(strcat("set(handles.options", visible))
                    eval(strcat("set(handles.add", visible))
                    eval(strcat("set(handles.add", enable))
                    eval(strcat("set(handles.add", string(i-1), ...
                        ",'String', 'ADD')"))
                    eval(strcat("set(handles.measure", enable))
                    set_measures(hObject, eventdata, handles, i-2);
                    break;
                end
                meas_str = eval(strcat("get(handles.measure", ...
                    string(i), ", 'String');"));
                eval(strcat("set(handles.Areas", string(i), ...
                        ", 'Value', 0)"))
                eval(strcat("set(handles.Channels", string(i), ...
                        ", 'Value', 0)"))
                eval(strcat("set(handles.Global", string(i), ...
                        ", 'Value', 0)"))
                eval(strcat("set(handles.Asymmetry", string(i), ...
                        ", 'Value', 0)"))
                text = strcat(string(i-1), ", 'String', '", add_str, "')");
                eval(strcat("set(handles.measure", string(i-1), ...
                    ", 'String', '",meas_str, "')"))
                eval(strcat("set(handles.add", text))
            end
        catch
            break;
        end
    end

%% Features Creation and Callback functions
function measure1_Callback(hObject, eventdata, handles)
function measure1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure3_Callback(hObject, eventdata, handles)
function measure3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure4_Callback(hObject, eventdata, handles)
function measure4_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels4_Callback(hObject, eventdata, handles)
function Global4_Callback(hObject, eventdata, handles)
function Areas4_Callback(hObject, eventdata, handles)
function Asymmetry4_Callback(hObject, eventdata, handles)
function checkbox43_Callback(hObject, eventdata, handles)
function measure5_Callback(hObject, eventdata, handles)
function measure5_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure6_Callback(hObject, eventdata, handles)
function measure6_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels6_Callback(hObject, eventdata, handles)
function Global6_Callback(hObject, eventdata, handles)
function Areas6_Callback(hObject, eventdata, handles)
function Asymmetry6_Callback(hObject, eventdata, handles)
function Channels5_Callback(hObject, eventdata, handles)
function Global5_Callback(hObject, eventdata, handles)
function Areas5_Callback(hObject, eventdata, handles)
function Asymmetry5_Callback(hObject, eventdata, handles)
function checkbox48_Callback(hObject, eventdata, handles)
function checkbox58_Callback(hObject, eventdata, handles)
function measure7_Callback(hObject, eventdata, handles)
function measure7_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels7_Callback(hObject, eventdata, handles)
function Global7_Callback(hObject, eventdata, handles)
function Areas7_Callback(hObject, eventdata, handles)
function Asymmetry7_Callback(hObject, eventdata, handles)
function checkbox63_Callback(hObject, eventdata, handles)
function measure8_Callback(hObject, eventdata, handles)
function measure8_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels8_Callback(hObject, eventdata, handles)
function Global8_Callback(hObject, eventdata, handles)
function Areas8_Callback(hObject, eventdata, handles)
function Asymmetry8_Callback(hObject, eventdata, handles)
function checkbox68_Callback(hObject, eventdata, handles)
function measure9_Callback(hObject, eventdata, handles)
function measure9_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure10_Callback(hObject, eventdata, handles)
function measure10_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels10_Callback(hObject, eventdata, handles)
function Global10_Callback(hObject, eventdata, handles)
function Areas10_Callback(hObject, eventdata, handles)
function Asymmetry10_Callback(hObject, eventdata, handles)
function Channels9_Callback(hObject, eventdata, handles)
function Global9_Callback(hObject, eventdata, handles)
function Areas9_Callback(hObject, eventdata, handles)
function Asymmetry9_Callback(hObject, eventdata, handles)
function checkbox73_Callback(hObject, eventdata, handles)
function checkbox78_Callback(hObject, eventdata, handles)
function measure11_Callback(hObject, eventdata, handles)
function measure11_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels11_Callback(hObject, eventdata, handles)
function Global11_Callback(hObject, eventdata, handles)
function Areas11_Callback(hObject, eventdata, handles)
function Asymmetry11_Callback(hObject, eventdata, handles)
function checkbox83_Callback(hObject, eventdata, handles)
function measure12_Callback(hObject, eventdata, handles)
function measure12_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure13_Callback(hObject, eventdata, handles)
function measure13_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels13_Callback(hObject, eventdata, handles)
function Global13_Callback(hObject, eventdata, handles)
function Areas13_Callback(hObject, eventdata, handles)
function Asymmetry13_Callback(hObject, eventdata, handles)
function Channels12_Callback(hObject, eventdata, handles)
function Global12_Callback(hObject, eventdata, handles)
function Areas12_Callback(hObject, eventdata, handles)
function Asymmetry12_Callback(hObject, eventdata, handles)
function checkbox88_Callback(hObject, eventdata, handles)
function checkbox93_Callback(hObject, eventdata, handles)
function measure14_Callback(hObject, eventdata, handles)
function measure14_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure15_Callback(hObject, eventdata, handles)
function measure15_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels15_Callback(hObject, eventdata, handles)
function Global15_Callback(hObject, eventdata, handles)
function Areas15_Callback(hObject, eventdata, handles)
function Asymmetry15_Callback(hObject, eventdata, handles)
function Channels14_Callback(hObject, eventdata, handles)
function Global14_Callback(hObject, eventdata, handles)
function Areas14_Callback(hObject, eventdata, handles)
function Asymmetry14_Callback(hObject, eventdata, handles)
function checkbox98_Callback(hObject, eventdata, handles)
function checkbox103_Callback(hObject, eventdata, handles)
function measure16_Callback(hObject, eventdata, handles)
function measure16_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure17_Callback(hObject, eventdata, handles)
function measure17_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels17_Callback(hObject, eventdata, handles)
function Global17_Callback(hObject, eventdata, handles)
function Areas17_Callback(hObject, eventdata, handles)
function Asymmetry17_Callback(hObject, eventdata, handles)
function add17_Callback(hObject, eventdata, handles)
function Channels16_Callback(hObject, eventdata, handles)
function Global16_Callback(hObject, eventdata, handles)
function Areas16_Callback(hObject, eventdata, handles)
function Asymmetry16_Callback(hObject, eventdata, handles)
function checkbox108_Callback(hObject, eventdata, handles)
function checkbox113_Callback(hObject, eventdata, handles)
function measure18_Callback(hObject, eventdata, handles)
function measure18_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure19_Callback(hObject, eventdata, handles)
function measure19_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure20_Callback(hObject, eventdata, handles)
function measure20_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure21_Callback(hObject, eventdata, handles)
function measure21_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels21_Callback(hObject, eventdata, handles)
function Global21_Callback(hObject, eventdata, handles)
function Areas21_Callback(hObject, eventdata, handles)
function Asymmetry21_Callback(hObject, eventdata, handles)
function Channels20_Callback(hObject, eventdata, handles)
function Global20_Callback(hObject, eventdata, handles)
function Areas20_Callback(hObject, eventdata, handles)
function Asymmetry20_Callback(hObject, eventdata, handles)
function Channels19_Callback(hObject, eventdata, handles)
function Global19_Callback(hObject, eventdata, handles)
function Areas19_Callback(hObject, eventdata, handles)
function Asymmetry19_Callback(hObject, eventdata, handles)
function Channels18_Callback(hObject, eventdata, handles)
function Global18_Callback(hObject, eventdata, handles)
function Areas18_Callback(hObject, eventdata, handles)
function Asymmetry18_Callback(hObject, eventdata, handles)
function checkbox118_Callback(hObject, eventdata, handles)
function checkbox123_Callback(hObject, eventdata, handles)
function checkbox128_Callback(hObject, eventdata, handles)
function checkbox133_Callback(hObject, eventdata, handles)
function measure22_Callback(hObject, eventdata, handles)
function measure22_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure23_Callback(hObject, eventdata, handles)
function measure23_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure24_Callback(hObject, eventdata, handles)
function measure24_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure25_Callback(hObject, eventdata, handles)
function measure25_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels25_Callback(hObject, eventdata, handles)
function Global25_Callback(hObject, eventdata, handles)
function Areas25_Callback(hObject, eventdata, handles)
function Asymmetry25_Callback(hObject, eventdata, handles)
function Channels24_Callback(hObject, eventdata, handles)
function Global24_Callback(hObject, eventdata, handles)
function Areas24_Callback(hObject, eventdata, handles)
function Asymmetry24_Callback(hObject, eventdata, handles)
function Global23_Callback(hObject, eventdata, handles)
function Areas23_Callback(hObject, eventdata, handles)
function Asymmetry23_Callback(hObject, eventdata, handles)
function Channels22_Callback(hObject, eventdata, handles)
function Global22_Callback(hObject, eventdata, handles)
function Areas22_Callback(hObject, eventdata, handles)
function Asymmetry22_Callback(hObject, eventdata, handles)
function checkbox138_Callback(hObject, eventdata, handles)
function checkbox143_Callback(hObject, eventdata, handles)
function checkbox148_Callback(hObject, eventdata, handles)
function checkbox153_Callback(hObject, eventdata, handles)
function measure26_Callback(hObject, eventdata, handles)
function measure26_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure27_Callback(hObject, eventdata, handles)
function measure27_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels27_Callback(hObject, eventdata, handles)
function Global27_Callback(hObject, eventdata, handles)
function Areas27_Callback(hObject, eventdata, handles)
function Asymmetry27_Callback(hObject, eventdata, handles)
function Channels26_Callback(hObject, eventdata, handles)
function Global26_Callback(hObject, eventdata, handles)
function Areas26_Callback(hObject, eventdata, handles)
function Asymmetry26_Callback(hObject, eventdata, handles)
function checkbox158_Callback(hObject, eventdata, handles)
function checkbox163_Callback(hObject, eventdata, handles)
function measure28_Callback(hObject, eventdata, handles)
function measure28_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels28_Callback(hObject, eventdata, handles)
function Global28_Callback(hObject, eventdata, handles)
function Areas28_Callback(hObject, eventdata, handles)
function Asymmetry28_Callback(hObject, eventdata, handles)
function add28_Callback(hObject, eventdata, handles)
function checkbox168_Callback(hObject, eventdata, handles)
function measure29_Callback(hObject, eventdata, handles)
function measure29_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels29_Callback(hObject, eventdata, handles)
function Global29_Callback(hObject, eventdata, handles)
function Areas29_Callback(hObject, eventdata, handles)
function Asymmetry29_Callback(hObject, eventdata, handles)
function checkbox173_Callback(hObject, eventdata, handles)
function measure30_Callback(hObject, eventdata, handles)
function measure30_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels30_Callback(hObject, eventdata, handles)
function Global30_Callback(hObject, eventdata, handles)
function Areas30_Callback(hObject, eventdata, handles)
function Asymmetry30_Callback(hObject, eventdata, handles)
function checkbox178_Callback(hObject, eventdata, handles)
function measure31_Callback(hObject, eventdata, handles)
function measure31_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels31_Callback(hObject, eventdata, handles)
function Global31_Callback(hObject, eventdata, handles)
function Areas31_Callback(hObject, eventdata, handles)
function Asymmetry31_Callback(hObject, eventdata, handles)
function checkbox183_Callback(hObject, eventdata, handles)
function measure32_Callback(hObject, eventdata, handles)
function measure32_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels32_Callback(hObject, eventdata, handles)
function Global32_Callback(hObject, eventdata, handles)
function Areas32_Callback(hObject, eventdata, handles)
function Asymmetry32_Callback(hObject, eventdata, handles)
function checkbox188_Callback(hObject, eventdata, handles)
function measure33_Callback(hObject, eventdata, handles)
function measure33_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels33_Callback(hObject, eventdata, handles)
function Global33_Callback(hObject, eventdata, handles)
function Areas33_Callback(hObject, eventdata, handles)
function Asymmetry33_Callback(hObject, eventdata, handles)
function checkbox193_Callback(hObject, eventdata, handles)
function measure34_Callback(hObject, eventdata, handles)
function measure34_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels34_Callback(hObject, eventdata, handles)
function Global34_Callback(hObject, eventdata, handles)
function Areas34_Callback(hObject, eventdata, handles)
function Asymmetry34_Callback(hObject, eventdata, handles)
function checkbox198_Callback(hObject, eventdata, handles)
function measure35_Callback(hObject, eventdata, handles)
function measure35_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels35_Callback(hObject, eventdata, handles)
function Global35_Callback(hObject, eventdata, handles)
function Areas35_Callback(hObject, eventdata, handles)
function Asymmetry35_Callback(hObject, eventdata, handles)
function checkbox203_Callback(hObject, eventdata, handles)
function measure36_Callback(hObject, eventdata, handles)
function measure36_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels36_Callback(hObject, eventdata, handles)
function Global36_Callback(hObject, eventdata, handles)
function Areas36_Callback(hObject, eventdata, handles)
function Asymmetry36_Callback(hObject, eventdata, handles)
function checkbox208_Callback(hObject, eventdata, handles)
function measure37_Callback(hObject, eventdata, handles)
function measure37_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels37_Callback(hObject, eventdata, handles)
function Global37_Callback(hObject, eventdata, handles)
function Areas37_Callback(hObject, eventdata, handles)
function Asymmetry37_Callback(hObject, eventdata, handles)
function checkbox213_Callback(hObject, eventdata, handles)
function measure38_Callback(hObject, eventdata, handles)
function measure38_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels38_Callback(hObject, eventdata, handles)
function Global38_Callback(hObject, eventdata, handles)
function Areas38_Callback(hObject, eventdata, handles)
function Asymmetry38_Callback(hObject, eventdata, handles)
function checkbox218_Callback(hObject, eventdata, handles)
function measure39_Callback(hObject, eventdata, handles)
function measure39_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure40_Callback(hObject, eventdata, handles)
function measure40_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels40_Callback(hObject, eventdata, handles)
function Global40_Callback(hObject, eventdata, handles)
function Areas40_Callback(hObject, eventdata, handles)
function Asymmetry40_Callback(hObject, eventdata, handles)
function add40_Callback(hObject, eventdata, handles)
function Channels39_Callback(hObject, eventdata, handles)
function Global39_Callback(hObject, eventdata, handles)
function Areas39_Callback(hObject, eventdata, handles)
function Asymmetry39_Callback(hObject, eventdata, handles)
function checkbox223_Callback(hObject, eventdata, handles)
function checkbox228_Callback(hObject, eventdata, handles)
function measures41_Callback(hObject, eventdata, handles)
function measures41_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels41_Callback(hObject, eventdata, handles)
function Global41_Callback(hObject, eventdata, handles)
function Areas41_Callback(hObject, eventdata, handles)
function Asymmetry41_Callback(hObject, eventdata, handles)
function checkbox233_Callback(hObject, eventdata, handles)
function measure42_Callback(hObject, eventdata, handles)
function measure42_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Channels42_Callback(hObject, eventdata, handles)
function Global42_Callback(hObject, eventdata, handles)
function Areas42_Callback(hObject, eventdata, handles)
function Asymmetry42_Callback(hObject, eventdata, handles)
function checkbox238_Callback(hObject, eventdata, handles)
function measure43_Callback(hObject, eventdata, handles)
function measure43_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure44_Callback(hObject, eventdata, handles)
function measure44_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels44_Callback(hObject, eventdata, handles)
function Global44_Callback(hObject, eventdata, handles)
function Areas44_Callback(hObject, eventdata, handles)
function Asymmetry44_Callback(hObject, eventdata, handles)
function Channels43_Callback(hObject, eventdata, handles)
function Global43_Callback(hObject, eventdata, handles)
function Areas43_Callback(hObject, eventdata, handles)
function Asymmetry43_Callback(hObject, eventdata, handles)
function checkbox248_Callback(hObject, eventdata, handles)
function checkbox253_Callback(hObject, eventdata, handles)
function measure45_Callback(hObject, eventdata, handles)
function measure45_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels45_Callback(hObject, eventdata, handles)
function Global45_Callback(hObject, eventdata, handles)
function Areas45_Callback(hObject, eventdata, handles)
function Asymmetry45_Callback(hObject, eventdata, handles)
function checkbox258_Callback(hObject, eventdata, handles)
function measure46_Callback(hObject, eventdata, handles)
function measure46_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels46_Callback(hObject, eventdata, handles)
function Global46_Callback(hObject, eventdata, handles)
function Areas46_Callback(hObject, eventdata, handles)
function Asymmetry46_Callback(hObject, eventdata, handles)
function checkbox263_Callback(hObject, eventdata, handles)
function measure47_Callback(hObject, eventdata, handles)
function measure47_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels47_Callback(hObject, eventdata, handles)
function Global47_Callback(hObject, eventdata, handles)
function Areas47_Callback(hObject, eventdata, handles)
function Asymmetry47_Callback(hObject, eventdata, handles)
function checkbox268_Callback(hObject, eventdata, handles)
function measure48_Callback(hObject, eventdata, handles)
function measure48_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels48_Callback(hObject, eventdata, handles)
function Global48_Callback(hObject, eventdata, handles)
function Areas48_Callback(hObject, eventdata, handles)
function Asymmetry48_Callback(hObject, eventdata, handles)
function checkbox273_Callback(hObject, eventdata, handles)
function measure49_Callback(hObject, eventdata, handles)
function measure49_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure50_Callback(hObject, eventdata, handles)
function measure50_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels50_Callback(hObject, eventdata, handles)
function Global50_Callback(hObject, eventdata, handles)
function Areas50_Callback(hObject, eventdata, handles)
function Asymmetry50_Callback(hObject, eventdata, handles)
function Channels49_Callback(hObject, eventdata, handles)
function Global49_Callback(hObject, eventdata, handles)
function Areas49_Callback(hObject, eventdata, handles)
function Asymmetry49_Callback(hObject, eventdata, handles)
function checkbox278_Callback(hObject, eventdata, handles)
function checkbox283_Callback(hObject, eventdata, handles)
function measure51_Callback(hObject, eventdata, handles)
function measure51_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels51_Callback(hObject, eventdata, handles)
function Global51_Callback(hObject, eventdata, handles)
function Areas51_Callback(hObject, eventdata, handles)
function Asymmetry51_Callback(hObject, eventdata, handles)
function checkbox288_Callback(hObject, eventdata, handles)
function measure52_Callback(hObject, eventdata, handles)
function measure52_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure53_Callback(hObject, eventdata, handles)
function measure53_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels53_Callback(hObject, eventdata, handles)
function Global53_Callback(hObject, eventdata, handles)
function Areas53_Callback(hObject, eventdata, handles)
function Asymmetry53_Callback(hObject, eventdata, handles)
function Channels52_Callback(hObject, eventdata, handles)
function Global52_Callback(hObject, eventdata, handles)
function Areas52_Callback(hObject, eventdata, handles)
function Asymmetry52_Callback(hObject, eventdata, handles)
function checkbox293_Callback(hObject, eventdata, handles)
function checkbox298_Callback(hObject, eventdata, handles)
function measure54_Callback(hObject, eventdata, handles)
function measure54_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure55_Callback(hObject, eventdata, handles)
function measure55_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels55_Callback(hObject, eventdata, handles)
function Global55_Callback(hObject, eventdata, handles)
function Areas55_Callback(hObject, eventdata, handles)
function Asymmetry55_Callback(hObject, eventdata, handles)
function Channels54_Callback(hObject, eventdata, handles)
function Global54_Callback(hObject, eventdata, handles)
function Areas54_Callback(hObject, eventdata, handles)
function Asymmetry54_Callback(hObject, eventdata, handles)
function checkbox303_Callback(hObject, eventdata, handles)
function checkbox308_Callback(hObject, eventdata, handles)
function measure56_Callback(hObject, eventdata, handles)
function measure56_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure57_Callback(hObject, eventdata, handles)
function measure57_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels57_Callback(hObject, eventdata, handles)
function Global57_Callback(hObject, eventdata, handles)
function Areas57_Callback(hObject, eventdata, handles)
function Asymmetry57_Callback(hObject, eventdata, handles)
function Channels56_Callback(hObject, eventdata, handles)
function Global56_Callback(hObject, eventdata, handles)
function Areas56_Callback(hObject, eventdata, handles)
function Asymmetry56_Callback(hObject, eventdata, handles)
function checkbox313_Callback(hObject, eventdata, handles)
function checkbox318_Callback(hObject, eventdata, handles)
function measure58_Callback(hObject, eventdata, handles)
function measure58_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure59_Callback(hObject, eventdata, handles)
function measure59_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function measure60_Callback(hObject, eventdata, handles)
function measure60_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function Channels60_Callback(hObject, eventdata, handles)
function Global60_Callback(hObject, eventdata, handles)
function Areas60_Callback(hObject, eventdata, handles)
function Asymmetry60_Callback(hObject, eventdata, handles)
function Channels59_Callback(hObject, eventdata, handles)
function Global59_Callback(hObject, eventdata, handles)
function Areas59_Callback(hObject, eventdata, handles)
function Asymmetry59_Callback(hObject, eventdata, handles)
function Channels58_Callback(hObject, eventdata, handles)
function Global58_Callback(hObject, eventdata, handles)
function Areas58_Callback(hObject, eventdata, handles)
function Asymmetry58_Callback(hObject, eventdata, handles)
function checkbox323_Callback(hObject, eventdata, handles)
function checkbox328_Callback(hObject, eventdata, handles)
function checkbox333_Callback(hObject, eventdata, handles)