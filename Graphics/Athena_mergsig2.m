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
% This function updates the interface if a measure is added or removed.
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
% This function updates the interface when a measure is removed.
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


% --- Executes on selection change in measure31.
function measure31_Callback(hObject, eventdata, handles)
% hObject    handle to measure31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure31 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure31


% --- Executes during object creation, after setting all properties.
function measure31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels31.
function Channels31_Callback(hObject, eventdata, handles)
% hObject    handle to Channels31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels31


% --- Executes on button press in Global31.
function Global31_Callback(hObject, eventdata, handles)
% hObject    handle to Global31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global31


% --- Executes on button press in Areas31.
function Areas31_Callback(hObject, eventdata, handles)
% hObject    handle to Areas31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas31


% --- Executes on button press in Asymmetry31.
function Asymmetry31_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry31


% --- Executes on button press in checkbox183.
function checkbox183_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox183 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox183


% --- Executes on selection change in measure32.
function measure32_Callback(hObject, eventdata, handles)
% hObject    handle to measure32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure32 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure32


% --- Executes during object creation, after setting all properties.
function measure32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels32.
function Channels32_Callback(hObject, eventdata, handles)
% hObject    handle to Channels32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels32


% --- Executes on button press in Global32.
function Global32_Callback(hObject, eventdata, handles)
% hObject    handle to Global32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global32


% --- Executes on button press in Areas32.
function Areas32_Callback(hObject, eventdata, handles)
% hObject    handle to Areas32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas32


% --- Executes on button press in Asymmetry32.
function Asymmetry32_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry32


% --- Executes on button press in checkbox188.
function checkbox188_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox188 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox188


% --- Executes on selection change in measure33.
function measure33_Callback(hObject, eventdata, handles)
% hObject    handle to measure33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure33 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure33


% --- Executes during object creation, after setting all properties.
function measure33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels33.
function Channels33_Callback(hObject, eventdata, handles)
% hObject    handle to Channels33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels33


% --- Executes on button press in Global33.
function Global33_Callback(hObject, eventdata, handles)
% hObject    handle to Global33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global33


% --- Executes on button press in Areas33.
function Areas33_Callback(hObject, eventdata, handles)
% hObject    handle to Areas33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas33


% --- Executes on button press in Asymmetry33.
function Asymmetry33_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry33


% --- Executes on button press in checkbox193.
function checkbox193_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox193 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox193


% --- Executes on selection change in measure34.
function measure34_Callback(hObject, eventdata, handles)
% hObject    handle to measure34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure34 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure34


% --- Executes during object creation, after setting all properties.
function measure34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels34.
function Channels34_Callback(hObject, eventdata, handles)
% hObject    handle to Channels34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels34


% --- Executes on button press in Global34.
function Global34_Callback(hObject, eventdata, handles)
% hObject    handle to Global34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global34


% --- Executes on button press in Areas34.
function Areas34_Callback(hObject, eventdata, handles)
% hObject    handle to Areas34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas34


% --- Executes on button press in Asymmetry34.
function Asymmetry34_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry34


% --- Executes on button press in checkbox198.
function checkbox198_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox198 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox198


% --- Executes on selection change in measure35.
function measure35_Callback(hObject, eventdata, handles)
% hObject    handle to measure35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure35 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure35


% --- Executes during object creation, after setting all properties.
function measure35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels35.
function Channels35_Callback(hObject, eventdata, handles)
% hObject    handle to Channels35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels35


% --- Executes on button press in Global35.
function Global35_Callback(hObject, eventdata, handles)
% hObject    handle to Global35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global35


% --- Executes on button press in Areas35.
function Areas35_Callback(hObject, eventdata, handles)
% hObject    handle to Areas35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas35


% --- Executes on button press in Asymmetry35.
function Asymmetry35_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry35


% --- Executes on button press in checkbox203.
function checkbox203_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox203 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox203


% --- Executes on selection change in measure36.
function measure36_Callback(hObject, eventdata, handles)
% hObject    handle to measure36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure36 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure36


% --- Executes during object creation, after setting all properties.
function measure36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels36.
function Channels36_Callback(hObject, eventdata, handles)
% hObject    handle to Channels36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels36


% --- Executes on button press in Global36.
function Global36_Callback(hObject, eventdata, handles)
% hObject    handle to Global36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global36


% --- Executes on button press in Areas36.
function Areas36_Callback(hObject, eventdata, handles)
% hObject    handle to Areas36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas36


% --- Executes on button press in Asymmetry36.
function Asymmetry36_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry36


% --- Executes on button press in checkbox208.
function checkbox208_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox208 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox208


% --- Executes on selection change in measure37.
function measure37_Callback(hObject, eventdata, handles)
% hObject    handle to measure37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure37 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure37


% --- Executes during object creation, after setting all properties.
function measure37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels37.
function Channels37_Callback(hObject, eventdata, handles)
% hObject    handle to Channels37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels37


% --- Executes on button press in Global37.
function Global37_Callback(hObject, eventdata, handles)
% hObject    handle to Global37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global37


% --- Executes on button press in Areas37.
function Areas37_Callback(hObject, eventdata, handles)
% hObject    handle to Areas37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas37


% --- Executes on button press in Asymmetry37.
function Asymmetry37_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry37


% --- Executes on button press in checkbox213.
function checkbox213_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox213 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox213


% --- Executes on selection change in measure38.
function measure38_Callback(hObject, eventdata, handles)
% hObject    handle to measure38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure38 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure38


% --- Executes during object creation, after setting all properties.
function measure38_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels38.
function Channels38_Callback(hObject, eventdata, handles)
% hObject    handle to Channels38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels38


% --- Executes on button press in Global38.
function Global38_Callback(hObject, eventdata, handles)
% hObject    handle to Global38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global38


% --- Executes on button press in Areas38.
function Areas38_Callback(hObject, eventdata, handles)
% hObject    handle to Areas38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas38


% --- Executes on button press in Asymmetry38.
function Asymmetry38_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry38


% --- Executes on button press in checkbox218.
function checkbox218_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox218 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox218


% --- Executes on selection change in measure39.
function measure39_Callback(hObject, eventdata, handles)
% hObject    handle to measure39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure39 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure39


% --- Executes during object creation, after setting all properties.
function measure39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure40.
function measure40_Callback(hObject, eventdata, handles)
% hObject    handle to measure40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure40 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure40


% --- Executes during object creation, after setting all properties.
function measure40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels40.
function Channels40_Callback(hObject, eventdata, handles)
% hObject    handle to Channels40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels40


% --- Executes on button press in Global40.
function Global40_Callback(hObject, eventdata, handles)
% hObject    handle to Global40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global40


% --- Executes on button press in Areas40.
function Areas40_Callback(hObject, eventdata, handles)
% hObject    handle to Areas40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas40


% --- Executes on button press in Asymmetry40.
function Asymmetry40_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry40


% --- Executes on button press in add40.
function add40_Callback(hObject, eventdata, handles)
% hObject    handle to add40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Channels39.
function Channels39_Callback(hObject, eventdata, handles)
% hObject    handle to Channels39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels39


% --- Executes on button press in Global39.
function Global39_Callback(hObject, eventdata, handles)
% hObject    handle to Global39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global39


% --- Executes on button press in Areas39.
function Areas39_Callback(hObject, eventdata, handles)
% hObject    handle to Areas39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas39


% --- Executes on button press in Asymmetry39.
function Asymmetry39_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry39


% --- Executes on button press in checkbox223.
function checkbox223_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox223 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox223


% --- Executes on button press in checkbox228.
function checkbox228_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox228 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox228


% --- Executes on selection change in measures41.
function measures41_Callback(hObject, eventdata, handles)
% hObject    handle to measures41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measures41 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measures41


% --- Executes during object creation, after setting all properties.
function measures41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measures41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels41.
function Channels41_Callback(hObject, eventdata, handles)
% hObject    handle to Channels41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels41


% --- Executes on button press in Global41.
function Global41_Callback(hObject, eventdata, handles)
% hObject    handle to Global41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global41


% --- Executes on button press in Areas41.
function Areas41_Callback(hObject, eventdata, handles)
% hObject    handle to Areas41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas41


% --- Executes on button press in Asymmetry41.
function Asymmetry41_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry41


% --- Executes on button press in checkbox233.
function checkbox233_Callback(hObject, eventdata, handles)
function measure42_Callback(hObject, eventdata, handles)
function measure42_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Channels42_Callback(hObject, eventdata, handles)
function Global42_Callback(hObject, eventdata, handles)
function Areas42_Callback(hObject, eventdata, handles)
function Asymmetry42_Callback(hObject, eventdata, handles)
function checkbox238_Callback(hObject, eventdata, handles)


% --- Executes on selection change in measure43.
function measure43_Callback(hObject, eventdata, handles)
% hObject    handle to measure43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure43 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure43


% --- Executes during object creation, after setting all properties.
function measure43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure44.
function measure44_Callback(hObject, eventdata, handles)
% hObject    handle to measure44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure44 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure44


% --- Executes during object creation, after setting all properties.
function measure44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels44.
function Channels44_Callback(hObject, eventdata, handles)
% hObject    handle to Channels44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels44


% --- Executes on button press in Global44.
function Global44_Callback(hObject, eventdata, handles)
% hObject    handle to Global44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global44


% --- Executes on button press in Areas44.
function Areas44_Callback(hObject, eventdata, handles)
% hObject    handle to Areas44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas44


% --- Executes on button press in Asymmetry44.
function Asymmetry44_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry44


% --- Executes on button press in Channels43.
function Channels43_Callback(hObject, eventdata, handles)
% hObject    handle to Channels43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels43


% --- Executes on button press in Global43.
function Global43_Callback(hObject, eventdata, handles)
% hObject    handle to Global43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global43


% --- Executes on button press in Areas43.
function Areas43_Callback(hObject, eventdata, handles)
% hObject    handle to Areas43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas43


% --- Executes on button press in Asymmetry43.
function Asymmetry43_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry43


% --- Executes on button press in checkbox248.
function checkbox248_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox248 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox248


% --- Executes on button press in checkbox253.
function checkbox253_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox253 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox253


% --- Executes on selection change in measure45.
function measure45_Callback(hObject, eventdata, handles)
% hObject    handle to measure45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure45 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure45


% --- Executes during object creation, after setting all properties.
function measure45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels45.
function Channels45_Callback(hObject, eventdata, handles)
% hObject    handle to Channels45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels45


% --- Executes on button press in Global45.
function Global45_Callback(hObject, eventdata, handles)
% hObject    handle to Global45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global45


% --- Executes on button press in Areas45.
function Areas45_Callback(hObject, eventdata, handles)
% hObject    handle to Areas45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas45


% --- Executes on button press in Asymmetry45.
function Asymmetry45_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry45


% --- Executes on button press in checkbox258.
function checkbox258_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox258 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox258


% --- Executes on selection change in measure46.
function measure46_Callback(hObject, eventdata, handles)
% hObject    handle to measure46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure46 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure46


% --- Executes during object creation, after setting all properties.
function measure46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels46.
function Channels46_Callback(hObject, eventdata, handles)
% hObject    handle to Channels46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels46


% --- Executes on button press in Global46.
function Global46_Callback(hObject, eventdata, handles)
% hObject    handle to Global46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global46


% --- Executes on button press in Areas46.
function Areas46_Callback(hObject, eventdata, handles)
% hObject    handle to Areas46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas46


% --- Executes on button press in Asymmetry46.
function Asymmetry46_Callback(hObject, eventdata, handles)
function checkbox263_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox263 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox263


% --- Executes on selection change in measure47.
function measure47_Callback(hObject, eventdata, handles)
% hObject    handle to measure47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure47 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure47


% --- Executes during object creation, after setting all properties.
function measure47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels47.
function Channels47_Callback(hObject, eventdata, handles)
% hObject    handle to Channels47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels47


% --- Executes on button press in Global47.
function Global47_Callback(hObject, eventdata, handles)
% hObject    handle to Global47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global47


% --- Executes on button press in Areas47.
function Areas47_Callback(hObject, eventdata, handles)
% hObject    handle to Areas47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas47


% --- Executes on button press in Asymmetry47.
function Asymmetry47_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry47


% --- Executes on button press in checkbox268.
function checkbox268_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox268 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox268


% --- Executes on selection change in measure48.
function measure48_Callback(hObject, eventdata, handles)
% hObject    handle to measure48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure48 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure48


% --- Executes during object creation, after setting all properties.
function measure48_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels48.
function Channels48_Callback(hObject, eventdata, handles)
% hObject    handle to Channels48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels48


% --- Executes on button press in Global48.
function Global48_Callback(hObject, eventdata, handles)
% hObject    handle to Global48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global48


% --- Executes on button press in Areas48.
function Areas48_Callback(hObject, eventdata, handles)
% hObject    handle to Areas48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas48


% --- Executes on button press in Asymmetry48.
function Asymmetry48_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry48


% --- Executes on button press in checkbox273.
function checkbox273_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox273 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox273


% --- Executes on selection change in measure49.
function measure49_Callback(hObject, eventdata, handles)
% hObject    handle to measure49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure49 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure49


% --- Executes during object creation, after setting all properties.
function measure49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure50.
function measure50_Callback(hObject, eventdata, handles)
% hObject    handle to measure50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure50 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure50


% --- Executes during object creation, after setting all properties.
function measure50_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels50.
function Channels50_Callback(hObject, eventdata, handles)
% hObject    handle to Channels50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels50


% --- Executes on button press in Global50.
function Global50_Callback(hObject, eventdata, handles)
% hObject    handle to Global50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global50


% --- Executes on button press in Areas50.
function Areas50_Callback(hObject, eventdata, handles)
% hObject    handle to Areas50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas50


% --- Executes on button press in Asymmetry50.
function Asymmetry50_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry50


% --- Executes on button press in Channels49.
function Channels49_Callback(hObject, eventdata, handles)
% hObject    handle to Channels49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels49


% --- Executes on button press in Global49.
function Global49_Callback(hObject, eventdata, handles)
% hObject    handle to Global49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global49


% --- Executes on button press in Areas49.
function Areas49_Callback(hObject, eventdata, handles)
% hObject    handle to Areas49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas49


% --- Executes on button press in Asymmetry49.
function Asymmetry49_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry49


% --- Executes on button press in checkbox278.
function checkbox278_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox278 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox278


% --- Executes on button press in checkbox283.
function checkbox283_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox283 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox283


% --- Executes on selection change in measure51.
function measure51_Callback(hObject, eventdata, handles)
% hObject    handle to measure51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure51 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure51


% --- Executes during object creation, after setting all properties.
function measure51_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels51.
function Channels51_Callback(hObject, eventdata, handles)
% hObject    handle to Channels51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels51


% --- Executes on button press in Global51.
function Global51_Callback(hObject, eventdata, handles)
% hObject    handle to Global51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global51


% --- Executes on button press in Areas51.
function Areas51_Callback(hObject, eventdata, handles)
% hObject    handle to Areas51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas51


% --- Executes on button press in Asymmetry51.
function Asymmetry51_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry51


% --- Executes on button press in checkbox288.
function checkbox288_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox288 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox288


% --- Executes on selection change in measure52.
function measure52_Callback(hObject, eventdata, handles)
% hObject    handle to measure52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure52 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure52


% --- Executes during object creation, after setting all properties.
function measure52_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure53.
function measure53_Callback(hObject, eventdata, handles)
% hObject    handle to measure53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure53 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure53


% --- Executes during object creation, after setting all properties.
function measure53_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels53.
function Channels53_Callback(hObject, eventdata, handles)
% hObject    handle to Channels53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels53


% --- Executes on button press in Global53.
function Global53_Callback(hObject, eventdata, handles)
% hObject    handle to Global53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global53


% --- Executes on button press in Areas53.
function Areas53_Callback(hObject, eventdata, handles)
% hObject    handle to Areas53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas53


% --- Executes on button press in Asymmetry53.
function Asymmetry53_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry53


% --- Executes on button press in Channels52.
function Channels52_Callback(hObject, eventdata, handles)
% hObject    handle to Channels52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels52


% --- Executes on button press in Global52.
function Global52_Callback(hObject, eventdata, handles)
% hObject    handle to Global52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global52


% --- Executes on button press in Areas52.
function Areas52_Callback(hObject, eventdata, handles)
% hObject    handle to Areas52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas52


% --- Executes on button press in Asymmetry52.
function Asymmetry52_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry52


% --- Executes on button press in checkbox293.
function checkbox293_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox293 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox293


% --- Executes on button press in checkbox298.
function checkbox298_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox298 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox298


% --- Executes on selection change in measure54.
function measure54_Callback(hObject, eventdata, handles)
% hObject    handle to measure54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure54 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure54


% --- Executes during object creation, after setting all properties.
function measure54_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure55.
function measure55_Callback(hObject, eventdata, handles)
% hObject    handle to measure55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure55 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure55


% --- Executes during object creation, after setting all properties.
function measure55_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels55.
function Channels55_Callback(hObject, eventdata, handles)
% hObject    handle to Channels55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels55


% --- Executes on button press in Global55.
function Global55_Callback(hObject, eventdata, handles)
% hObject    handle to Global55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global55


% --- Executes on button press in Areas55.
function Areas55_Callback(hObject, eventdata, handles)
% hObject    handle to Areas55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas55


% --- Executes on button press in Asymmetry55.
function Asymmetry55_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry55


% --- Executes on button press in Channels54.
function Channels54_Callback(hObject, eventdata, handles)
% hObject    handle to Channels54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels54


% --- Executes on button press in Global54.
function Global54_Callback(hObject, eventdata, handles)
% hObject    handle to Global54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global54


% --- Executes on button press in Areas54.
function Areas54_Callback(hObject, eventdata, handles)
% hObject    handle to Areas54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas54


% --- Executes on button press in Asymmetry54.
function Asymmetry54_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry54


% --- Executes on button press in checkbox303.
function checkbox303_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox303 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox303


% --- Executes on button press in checkbox308.
function checkbox308_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox308 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox308


% --- Executes on selection change in measure56.
function measure56_Callback(hObject, eventdata, handles)
% hObject    handle to measure56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure56 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure56


% --- Executes during object creation, after setting all properties.
function measure56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure57.
function measure57_Callback(hObject, eventdata, handles)
% hObject    handle to measure57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure57 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure57


% --- Executes during object creation, after setting all properties.
function measure57_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels57.
function Channels57_Callback(hObject, eventdata, handles)
% hObject    handle to Channels57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels57


% --- Executes on button press in Global57.
function Global57_Callback(hObject, eventdata, handles)
% hObject    handle to Global57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global57


% --- Executes on button press in Areas57.
function Areas57_Callback(hObject, eventdata, handles)
% hObject    handle to Areas57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas57


% --- Executes on button press in Asymmetry57.
function Asymmetry57_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry57


% --- Executes on button press in Channels56.
function Channels56_Callback(hObject, eventdata, handles)
% hObject    handle to Channels56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels56


% --- Executes on button press in Global56.
function Global56_Callback(hObject, eventdata, handles)
% hObject    handle to Global56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global56


% --- Executes on button press in Areas56.
function Areas56_Callback(hObject, eventdata, handles)
% hObject    handle to Areas56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas56


% --- Executes on button press in Asymmetry56.
function Asymmetry56_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry56


% --- Executes on button press in checkbox313.
function checkbox313_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox313 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox313


% --- Executes on button press in checkbox318.
function checkbox318_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox318 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox318


% --- Executes on selection change in measure58.
function measure58_Callback(hObject, eventdata, handles)
% hObject    handle to measure58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure58 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure58


% --- Executes during object creation, after setting all properties.
function measure58_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure59.
function measure59_Callback(hObject, eventdata, handles)
% hObject    handle to measure59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure59 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure59


% --- Executes during object creation, after setting all properties.
function measure59_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in measure60.
function measure60_Callback(hObject, eventdata, handles)
% hObject    handle to measure60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns measure60 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from measure60


% --- Executes during object creation, after setting all properties.
function measure60_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measure60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Channels60.
function Channels60_Callback(hObject, eventdata, handles)
% hObject    handle to Channels60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels60


% --- Executes on button press in Global60.
function Global60_Callback(hObject, eventdata, handles)
% hObject    handle to Global60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global60


% --- Executes on button press in Areas60.
function Areas60_Callback(hObject, eventdata, handles)
% hObject    handle to Areas60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas60


% --- Executes on button press in Asymmetry60.
function Asymmetry60_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry60


% --- Executes on button press in Channels59.
function Channels59_Callback(hObject, eventdata, handles)
% hObject    handle to Channels59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels59


% --- Executes on button press in Global59.
function Global59_Callback(hObject, eventdata, handles)
% hObject    handle to Global59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global59


% --- Executes on button press in Areas59.
function Areas59_Callback(hObject, eventdata, handles)
% hObject    handle to Areas59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas59


% --- Executes on button press in Asymmetry59.
function Asymmetry59_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry59


% --- Executes on button press in Channels58.
function Channels58_Callback(hObject, eventdata, handles)
% hObject    handle to Channels58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Channels58


% --- Executes on button press in Global58.
function Global58_Callback(hObject, eventdata, handles)
% hObject    handle to Global58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Global58


% --- Executes on button press in Areas58.
function Areas58_Callback(hObject, eventdata, handles)
% hObject    handle to Areas58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Areas58


% --- Executes on button press in Asymmetry58.
function Asymmetry58_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetry58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Asymmetry58


% --- Executes on button press in checkbox323.
function checkbox323_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox323 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox323


% --- Executes on button press in checkbox328.
function checkbox328_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox328 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox328


% --- Executes on button press in checkbox333.
function checkbox333_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox333 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox333
