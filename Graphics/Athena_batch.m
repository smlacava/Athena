function varargout = Athena_batch(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_batch_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_batch_OutputFcn, ...
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

    
function Athena_batch_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    myImage = imread('untitled3.png');
    set(handles.axes3,'Units', 'pixels');
    resizePos = get(handles.axes3, 'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3, 'Units', 'normalized');
    addpath 'Auxiliary'
    if nargin >= 4
        set(handles.aux_dataPath, 'String', varargin{1})
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin == 7
        set(handles.aux_loc, 'String', varargin{4})
    end
        

function varargout = Athena_batch_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function sub_text_Callback(hObject, eventdata, handles)


function sub_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function dataFile_text_Callback(hObject, eventdata, handles)


function dataFile_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


function Run_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    addpath 'Batch'
    addpath 'Correlations'
    addpath 'Epochs Management'
    addpath 'Epochs Analysis'
    addpath 'Classification'
    addpath 'Measures'
    addpath 'Statistical Analysis'
    
    MEASURES = ["PLV", "PLI", "AEC", "AECo", "offset", "exponent", "PSDr"];
    MEASURESbg = ["offset", "exponent"];
    true = ["True", "true", "TRUE", "t", "1", "OK", "ok"];
	dataFile = char_check(get(handles.dataFile_text, 'String'));
    bg_color = [0.67 0.98 0.92];
    if not(exist(dataFile, 'file'))
        problem(strcat("File ", dataFile, " not found"))
        return
    end
    
    %dataPath, fs, cf, epNum, epTime, 
    %tStart, totBand, measure, Subjects, locations, 
    %Index, MeasureExtraction, EpochsAverage, EpochsAnalysis, IndexCorrelation, 
    %StatisticalAnalysis, MeasuresCorrelation, ClassificationData, Group_IC, Areas_IC,
    %Conservativeness_IC, Areas_EA, Areas_SA, Conservativeness_SA, Measure1, 
    %Measure2, Areas_MC, Group_MC, MergingData, MergingMeasures, MergingAreas, 
    %Subject, Classification, DefaultClassification, TrainPercentage, TreesNumber, 
    %BaggingValue, RandomSubspace, PruningDepth, Repetitions, MinimumClassExamples
    parameters = read_file(dataFile);
    
    dataPath = path_check(parameters{1});
    cf = parameters{3};
    nBands = length(cf)-1;
    measure = parameters{8};
    n_measures = length(measure);
    measurePath = cell(n_measures, 1);
    
    if not(exist(dataPath, 'dir'))
        problem(strcat('Directory ', dataPath, ' not found'))
        return
    end
    for m = 1:n_measures
        if strcmp(measure{m}, 'AECc')
            measure{m} = 'AECo';
        end
        if not(sum(strcmp(measure{m}, MEASURES)))
            problem(strcat(measure{m}, ' is an invalid measure'))
            return
        end
        measurePath{m} = path_check(strcat(dataPath, measure{m}));
        if not(exist(measurePath{m}, 'dir'))
            mkdir(measurePath{m});
        end
    end
 
    
    if sum(strcmp(parameters{12}, 'true'))
        for m = 1:n_measures
            if strcmp(measure{m}, 'PSDr') && length(parameters{7}) ~= 2
                problem('Invalid total band')
                return
            end
            [type, ~] = type_check(measure{m});
            if strcmp(measure{m}, 'PSDr') 
                PSDr(parameters{2}, cf, parameters{4}, parameters{5}, ...
                    dataPath, parameters{6}, parameters{7})
            elseif strcmp(measure{m}, 'offset') || ...
                    strcmp(measure{m}, 'exponent')
                    cf_bg = [cf(1), cf(end)];
                FOOOFer(parameters{2}, cf_bg, parameters{4}, ...
                    parameters{5}, dataPath, parameters{6}, type)
            else
                connectivity(parameters{2}, cf, parameters{4}, ...
                    parameters{5}, dataPath, parameters{6}, measure{m})
            end
            pause(1)
        end
    end
    
    
    if sum(strcmp(parameters{13}, 'true'))
        if not(exist(parameters{9}, 'file'))
            problem(strcat(parameters{9}, ' file not found'))
            return
        end
        for m = 1:n_measures
            if not(exist(path_check(strcat(path_check(strcat(dataPath, ...
                    measure{m})), 'Epmean')), 'dir'))
                mkdir(path_check(strcat(path_check(strcat(dataPath, ...
                    measure{m})), 'Epmean')))
            end
            locations_file = epmean_and_manage(dataPath, measure{m}, ...
                parameters{9}, parameters{10});
            if exist('auxiliary.txt', 'file')
                auxID = fopen('auxiliary.txt', 'a+');
            elseif exist(strcat(dataPath, 'auxiliary.txt'), 'file')
                auxID = fopen(strcat(dataPath, 'auxiliary.txt'), 'a+');
            end
            fseek(auxID, 0, 'eof');
            fprintf(auxID, '\nEpmean=true');
            fprintf(auxID, '\nSubjects=%s', parameters{9});
            if not(isempty(locations_file))
                fprintf(auxID, '\nLocations=%s', locations_file);
            else
                fprintf(auxID, '\nLocations=%s', ...
                    strcat(dataPath, 'Locations.mat'));
            end
            fclose(auxID);
        end
    end
    
    if sum(strcmp(parameters{14}, 'true'))
        if not(exist(parameters{10}, 'file'))
            problem(strcat("File ", parameters{10}, " not found"))
            return
        end
        Areas_EA = parameters{22};
        for m = 1:n_measures
            for i = 1:length(Areas_EA)
                epochs_analysis(dataPath, parameters{32}, ...
                    areas_check(Areas_EA{i,1}), measure{m}, ...
                    parameters{4}, nBands, parameters{10})
            end
        end
    end
    
    managedPath = cell(n_measures, 1);
    for m = 1:n_measures
        managedPath{m} = path_check(strcat(measurePath{m}, 'Epmean'));
    end
    if exist('locations_file', 'var') && ischar(locations_file)
        locations = load_data(locations_file);
    else
        locations = load_data(parameters{10});
        locations = locations(:, 1);
    end
    alpha = alpha_levelling(parameters{21}, nBands, length(locations));
    
    for m = 1:n_measures
        if not(exist(managedPath{m}, 'dir')) && ...
                sum([sum(strcmp(parameters{17}, true)), ...
                sum(strcmp(parameters{15}, true)), ...
                sum(strcmp(parameters{16}, true))]) > 0
            problem('Epochs Avarage not computed')
            return
        else
            cd(dataPath)
        
            Subjects = load_data(parameters{9});
            if sum(strcmp(parameters{15}, 'true'))
                if not(exist(parameters{11}, 'file'))
                    problem(strcat("File ", parameters{11}, " not found"))
                    return
                end
                Areas_IC = parameters{20};
                for i = 1:length(Areas_IC)
                    [data, ~, locs] = load_data(strcat(path_check(...
                        strcat(managedPath{m}, Areas_IC{i})), 'PAT.mat'));
                    if length(size(data)) == 3
                        nBands = size(data, 2);
                    else
                        nBands = 1;
                    end
                    RHO = zeros(length(locs), nBands);
                    P = RHO;
                    bands = string();
                    for j = 1:nBands
                        bands = [bands; strcat('Band', string(j))];
                    end
                    bands(1, :) = [];
                    bands = cellstr(bands);
                    [data, ~, locations] = load_data(char_check(strcat(...
                        path_check(strcat(managedPath{m}, ...
                        Areas_IC{i})), parameters{19}, '.mat')));
                    subs = {};
                    if strcmp(char_check(parameters{19}), 'PAT')
                        for s = 1:length(Subjects)
                            if patient_check(char_check(Subjects(s, end)))
                                subs = [subs, char_check(Subjects(s, 1))];
                            end
                        end
                    else
                        for s = 1:length(Subjects)
                            if not(patient_check(char_check(...
                                    Subjects(s, end))))
                                subs = [subs, char_check(Subjects(s, 1))];
                            end
                        end
                    end
                    index_correlation(data, subs, bands, measure{m}, ...
                    parameters{11}, alpha, bg_color, locations, P, RHO, ...
                        length(locations), nBands);
                end
                pause(2)
            end
        end
        
        if sum(strcmp(parameters{16}, 'true'))
            Areas_SA = parameters{23};
            for i = 1:length(Areas_SA)
                saPath = path_check(strcat(managedPath{m}, Areas_SA{i}));
                PAT = strcat(saPath, 'PAT.mat');
                HC = strcat(saPath, 'HC.mat');
                [PAT, ~, locs] = load_data(PAT);
                HC = load_data(HC);
                anType = areas_check(Areas_SA{i,1});
                statistical_analysis(HC, PAT, locs, ....
                    cons_check(parameters{24}), ...
                    dataPath, measure{m}, anType)
            end
        end
        
        if sum(strcmp(parameters{17}, 'true'))
            Areas_MC = parameters{27};
            for i = 1:length(Areas_MC)
                [xData, yData, nLoc, nBands, locs] = ...
                    batch_measures_correlation_settings(parameters{25}, ...
                    parameters{26}, dataPath, Areas_MC{i}, parameters{28});
                if isempty(nBands)
                    return;
                end
                bands = cell(1, nBands);
                for b = 1:nBands
                	bands{1, b} = char_check(strcat("Band ", string(b)));
                end
                measures_correlation(xData, yData, parameters{28}, ...
                    bands, {parameters{25}, parameters{26}}, alpha, ...
                    bg_color, locs, [], [], nLoc, nBands)   
            end
        end
    end
    
    if sum(strcmp(parameters{29}, 'true'))
    	MergingAreas = parameters{31};
        MergingMeasures = parameters{30};
        classification_data_settings(dataPath, MergingAreas, ...
            MergingMeasures);
    end
    
    if sum(strcmp(parameters{33}, 'true'))
        for i = 35:40
            if isnan(parameters{i})
                parameters{i} = [];
            end
        end
        statistics = classification(dataPath, parameters{35}, ...
            parameters{36}, parameters{37}, parameters{38}, ...
            parameters{39}, parameters{40}, parameters{41});
        resultDir = strcat(path_check(dataPath), 'Classification');
        if not(exist(resultDir, 'dir'))
            mkdir(resultDir);
        end
        save(strcat(path_check(resultDir), 'Statistics.mat'), 'statistics')
    end
    success()
    
    
function data_search_Callback(hObject, ~, handles)
    [i, ip] = uigetfile({'*.*'});
    if i ~= 0
        set(handles.dataFile_text, 'String', strcat(string(ip), string(i)))
    end


function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc] = GUI_transition(handles);
    close(Athena_batch)
    Athena(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)
