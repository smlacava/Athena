function varargout = Athena_mergsig(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_mergsig_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_mergsig_OutputFcn, ...
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

    
function Athena_mergsig_OpeningFcn(hObject, eventdata, handles, varargin)
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
        if not(exist(strcat(path_check(path), 'StatAn'), 'dir'))
            set(handles.sigData, 'Enable', 'off');
            set(handles.sigData, 'Value', 0)
            set(handles.allData, 'Value', 1)
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

    
function varargout = Athena_mergsig_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)
        set(handles.aux_dataPath, 'String', ...
            get(handles.dataPath_text, 'String'))
        

function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function checkTotal_Callback(hObject, eventdata, handles)


function checkGlobal_Callback(hObject, eventdata, handles)


function checkAreas_Callback(hObject, eventdata, handles)


function checkAsymmetry_Callback(hObject, eventdata, handles)


function checkPLI_Callback(hObject, eventdata, handles)


function checkPLV_Callback(hObject, eventdata, handles)


function checkAECc_Callback(hObject, eventdata, handles)


function checkPSDr_Callback(hObject, eventdata, handles)


function checkAEC_Callback(hObject, eventdata, handles)


function checkOffset_Callback(hObject, eventdata, handles)


function checkExponent_Callback(hObject, eventdata, handles)


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
    
    dataType = 'Significant';
    if get(handles.allData, 'Value') == 1
        dataType = 'All';
    end

    anType = [];
    if get(handles.checkAsymmetry, 'Value') == 1
        anType = [anType "asymmetry"];
    end
    if get(handles.checkTotal, 'Value') == 1
        anType = [anType "total"];
    end
    if get(handles.checkGlobal, 'Value') == 1
        anType = [anType "global"];
    end
    if get(handles.checkAreas, 'Value') == 1
        anType = [anType "areas"];
    end
    
    measType=[];
    if get(handles.checkPLI, 'Value') == 1
        measType=[measType "PLI"];
    end
    if get(handles.checkPLV, 'Value') == 1
        measType = [measType "PLV"];
    end
    if get(handles.checkAEC, 'Value') == 1
        measType = [measType "AEC"];
    end
    if get(handles.checkAECc, 'Value') == 1
        measType = [measType "AECo"];
    end
    if get(handles.checkPSDr, 'Value') == 1
        measType = [measType "PSDr"];
    end
    if get(handles.checkOffset, 'Value') == 1
        measType = [measType "Offset"];
    end
    if get(handles.checkExponent, 'Value') == 1
        measType = [measType "Exponent"];
    end
    if get(handles.checkCOH, 'Value') == 1
        measType = [measType "Coherence"];
    end
    if get(handles.checkICOH, 'Value') == 1
        measType = [measType "ICOH"];
    end
    
    value = 100;
    data = classification_data_settings(dataPath, anType, measType, ...
        dataType);
    if size(data, 2) == 1
        problem('There are not enough data parameters')
        return
    end
    [data, pc] = reduce_predictors(data, value);
    answer = user_decision(strcat("The resulting dataset is composed ", ...
        string(size(data, 2)-1), " features. Do you want to apply ", ...
        "the Principal Component Analysis on your data?"), ...
        "Dataset computed");
    close(pc)
    aux_data = data;
    while strcmpi(answer, 'yes')
        value = value_asking(100, 'PCA value', strcat("Choose the ", ...
            "minimum fraction of thhe total variance which has to be ", ...
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
            "you want to apply the Principal Component Analysis on ", ...
            "your data?"), "Dataset computed");
        close(pc)
    end
    data = aux_data;
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
        save(fullfile_check(strcat(path_check(dataPath), ...
            'Classification', filesep, ...
            'Classification_Data.mat')), 'data')
    end
    
    anType_text = '{';
    try
        anType_text = strcat(anType_text, "'", anType(1), "'");
        for i = 2:length(anType)
            anType_text = strcat(anType_text, ",'", anType(i), "'");
        end
    catch
    end
    anType_text = strcat(anType_text, '}');
    measType_text = '{';
    try
        measType_text = strcat(measType_text, "'", measType(1), "'");
        for i = 2:length(measType)
            measType_text = strcat(measType_text, ",'", measType(i), "'");
        end
    catch
    end
    measType_text = strcat(measType_text, '}');
    Athena_history_update(strcat('data=classification_data_settings(', ...
        strcat("'", dataPath, "'"), ',',  anType_text, ',', ...
        measType_text, ',',  strcat("'", dataType, "'"), ')'));
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
    close(Athena_mergsig)
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
    close(Athena_mergsig)
    Athena_selectClass(dataPath, measure, sub, loc, sub_types)


function allData_Callback(hObject, eventdata, handles)


function sigData_Callback(hObject, eventdata, handles)


function checkbox26_Callback(hObject, eventdata, handles)


function checkCOH_Callback(hObject, eventdata, handles)


function checkICOH_Callback(hObject, eventdata, handles)