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
    set(handles.axes3,'Units','pixels');
    resizePos = get(handles.axes3,'Position');
    myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.axes3);
    imshow(myImage);
    set(handles.axes3,'Units','normalized');
    if exist('auxiliary.txt', 'file')
        auxID=fopen('auxiliary.txt','r');
        fseek(auxID, 0, 'bof');
        dataPath_line=split(fgetl(auxID),'=');
        set(handles.dataPath_text,'String',dataPath_line(2))
        fclose(auxID);
    end
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
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function Run_Callback(~, eventdata, handles)
    auxPath=pwd;
    funDir=which('Athena.m');
    funDir=split(funDir,'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    addpath 'Batch'
    addpath 'Index Correlation'
    addpath 'Measures Correlation'
    addpath 'Epochs Management'
    addpath 'Epochs Analysis'
    addpath 'Classification'
    addpath 'Measures'
    addpath 'Statistical Analysis'
    
    MEASURES=["PLV", "PLI", "AEC", "AECo", "offset", "exponent", "PSDr"];
    MEASURESconn=["PLV", "PLI", "AEC", "AECo"];
    true=["True", "true", "TRUE", "t", "1", "OK", "ok"];
	dataFile=string_check(get(handles.dataPath_text,'String'));
    
    [dataPath, fs, cf, epNum, epTime, tStart, totBand, measure, ...
    Subjects, locations, Index, MeasureExtraction, EpochsAverage, ...
    EpochsAnalysis, IndexCorrelation, StatisticalAnalysis, ...
    MeasuresCorrelation, ClassificationData, Group_IC, Areas_IC, ...
    Conservativeness_IC, Areas_EA, Areas_SA, Conservativeness_SA, ...
    Measure1, Measure2, Areas_MC, Group_MC, MergingMeasures, ...
    MergingAreas, Subject]=read_file(dataFile);
    
    dataPath=path_check(dataPath);
    cd(dataPath)
    nBands=length(cf)-1;
    measurePath=strcat(dataPath,measure);
    measurePath=path_check(measurePath);
    addpath(measurePath)
    
    if not(exist(dataPath,'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    if not(sum(strcmp(measure,MEASURES)))
        problem(strcat(measure, " is an invalid measure"))
        return
    end
    if sum(strcmp(measure,MEASURESconn))
        connCheck=1;
        type="CONN";
    else
        connCheck=0;
        type=measure;
    end
 
    
    if sum(strcmp(MeasureExtraction, true))
        if strcmp(measure,"PSDr")&& length(totBand)~=2
            problem("Invalid total band")
            return
        end
        batch_measureExtraction(measure, fs, cf, epNum, epTime, ...
            dataPath, tStart, totBand);
        pause(1)
    end
    
    
    if sum(strcmp(EpochsAverage,true))
        if not(exist(Subjects,'file'))
            problem(strcat(Subjects, " file not found"))
            return
        end
        batch_epochsAverage(measurePath, type, Subjects)
    end
    
    if sum(strcmp(EpochsAnalysis,true))
        for i=1:length(Areas_EA)
            epochs_analysis(measurePath, Subject, areas_check(Areas_EA{i,1}), measure, ...
                epNum, nBands, locations)
        end
    end
    
    managedPath=strcat(measurePath,"Epmean");
    managedPath=path_check(managedPath);

    if not(exist(managedPath,'dir')) && ...
            sum([sum(strcmp(MeasuresCorrelation,true)), ...
            sum(strcmp(IndexCorrelation,true)), ...
            sum(strcmp(StatisticalAnalysis,true))])>0
        uiwait(msgbox('Epochs Avarage not computed','Error','custom',im));
    else
        cd(dataPath)
        
        if sum(strcmp(IndexCorrelation,true))
            for i=1:length(Areas_IC)
                if strcmp(Group_IC,"PAT")
                    sub=Subjects(Subjects(:,end)==1,1);
                else
                    sub=Subjects(Subjects(:,end)==1,0);
                end
                groupFile=string_check(strcat(managedPath, Group_IC, ...
                    "_em.mat"));
                [RHO, P, RHOsig, locList]=index_correlation(groupFile, ...
                    Index, locations, connCheck, ...
                    areas_check(Areas_IC{i,1}), Conservativeness_IC, ...
                    measure, sub);
                bands=string();
                for i=1:size(RHO,1)
                    bands=[bands; strcat('Band', string(i))];
                end
                bands(1,:)=[];
                bands=cellstr(bands);
        
                fc1 = figure('Name', 'Correlations - RHO', ...
                    'NumberTitle', 'off');
                rho = uitable(fc1, 'Data', RHO, 'Position', ...
                    [20 20 525 375], 'RowName', bands, 'ColumnName', ...
                    locList);
                fc2 = figure('Name', 'Correlations - p-value', ...
                    'NumberTitle', 'off');
                pcorr = uitable(fc2, 'Data', P, 'Position', ...
                    [20 20 525 375], 'RowName', bands, 'ColumnName', ...
                    locList);
                if size(RHOsig, 1)~=0 && ...
                        not(logical(sum(sum(strcmp(RHOsig, "")))))
                    fc3 = figure('Name', ...
                        'Correlations - Significative Results', ...
                        'NumberTitle', 'off');
                    rhos = uitable(fc3, 'Data', cellstr(RHOsig), ...
                        'Position', [20 20 525 375]);
                end
            end
            pause(2)
        end
    
    
        if sum(strcmp(StatisticalAnalysis,true))
            for i=1:length(Areas_SA)
                PAT=strcat(managedPath, 'PAT_em.mat');
                HC=strcat(managedPath, 'HC_em.mat');
                anType=areas_check(Areas_SA{i,1});
                [P, Psig, locList, data, dataSig]=mult_t_test(PAT, HC, ...
                    locations, connCheck, anType, ...
                    Conservativeness_SA);
                bands=string();
                for i=1:size(P,1)
                    bands=[bands; strcat('Band',string(i))];
                end
                bands(1,:)=[];
                bands=cellstr(bands);
                if length(size(data))==3
                    auxData=[];
                    for i=1:size(data,3)
                        auxData=[auxData data(:,:,i)];
                    end
                    data=auxData;
                    clear auxData;
                end
        
                fs1 = figure('Name','Data','NumberTitle','off');
                d = uitable(fs1,'Data',data,'Position',[20 20 525 375]);
                fs2 = figure('Name','Statistical Analysis - p-value','NumberTitle','off');
                p = uitable(fs2,'Data',P,'Position',[20 20 525 375],'RowName',bands,'ColumnName',locList);
        
                if size(Psig,1)~=0 && not(logical(sum(sum(strcmp(Psig,"")))))
                    fs3 = figure('Name','Statistical Analysis - Significant Results','NumberTitle','off');
                    ps = uitable(fs3,'Data',cellstr(Psig),'Position',[20 20 525 375]);
                end
        
                statanDir=limit_path(char(dataPath),measure);
                statanType=strcat(measure,'_',anType,'.mat');
                if not(exist(strcat(statanDir,'StatAn')))
                    mkdir(statanDir,'statAn')
                end
                statAnResult=struct();
                statAnResult.Psig=Psig;
                statAnResult.dataSig=dataSig;
                statanDir=strcat(statanDir,'StatAn');
                statanDir=path_check(statanDir);
                save(strcat(statanDir,statanType),"statAnResult")
            end
        end
    
        if sum(strcmp(MeasuresCorrelation,true))
            type=[string(Measure1) string(Measure2)];
            if strcmp(Group_MC,"PAT")
                dataPathG='PAT_em.mat';
            elseif strcmp(Group_MC,"HC")
                dataPathG='HC_em.mat';
            end
            for a=1:length(Areas_MC)
                for m=1:2
                    if sum(strcmp(type(m), ...
                            ["PLV", "PLI", "AEC", "AECo"]))==0
                        connCheckM=0;
                    else
                        connCheckM=1;
                    end
                    dataPathM=path_check(strcat(dataPath,type(m)));
                    dataPathM=path_check(strcat(dataPathM, "Epmean"));
                    dataPathM=strcat(dataPathM, dataPathG);
                    anType=areas_check(Areas_MC{a,1});
                    [d, locList]=measures_manager(dataPathM, locations, ...
                        connCheckM, anType);
                    if m==1
                        data1=d;
                    else
                        data2=d;
                    end
                end   
                type1=type(1);
                type2=type(2);
                nBands=size(data1,2);
                for i=1:length(locList) 
                    for j=1:nBands
                        correlation(data1(:,j,i), data2(:,j,i), ...
                            strcat("Band", string(j), " ", locList(i)), ...
                            type1, type2)
                    end
                end
            end
        end
    
        if sum(strcmp(ClassificationData,true))
            dataSig=[];
            Psig=[string() string() string() string()];
            SApath=strcat(dataPath, "statAn");
            SApath=path_check(SApath);
            for i=1:length(MergingAreas)
                for j=1:length(MergingMeasures)
                    SAfile=strcat(SApath,MergingMeasures{j},'_',MergingAreas{i},'.mat');
                    if exist(SAfile,'file')
                        load(SAfile)
                        dataSig=[dataSig, statAnResult.dataSig];
                        col=size(statAnResult.Psig,2);
                        if not(isempty(col))
                            if col==2
                                for r=1:size(statAnResult.Psig,1)
                                    Psig=[Psig; [MergingMeasures(j), MergingAreas(i), statAnResult.Psig(r,:)]];
                                end
                            else
                                for r=1:size(statAnResult.Psig,1)
                                    Psig=[Psig; [MergingMeasures(j), statAnResult.Psig(r,:)]];
                                end
                            end
                        end
                    end
                end
            end
            Psig(1,:)=[];
            
            SDfile=strcat(dataPath,"Significant_Data.csv");
            SRfile=strcat(dataPath,"Significant_Results.txt");
            if exist(SDfile,'file')
                delete(SDfile);
            end
            csvwrite(SDfile, dataSig);
            srID=fopen(SRfile,'w');
            for s=1:size(Psig,1)
                fprintf(srID,"%s %s %s %s\n", Psig(s,:));
            end
            fclose(srID);            
        end
    end
    success()
    
    
function data_search_Callback(hObject, ~, handles)
    [i,ip]=uigetfile;
    if i~=0
        set(handles.dataPath_text,'String',strcat(string(ip),string(i)))
    end


function back_Callback(hObject, eventdata, handles)
    dataPath = string_check(get(handles.aux_dataPath, 'String'));
    measure = string_check(get(handles.aux_measure, 'String'));
    sub = string_check(get(handles.aux_sub, 'String'));
    loc = string_check(get(handles.aux_loc, 'String'));
    close(Athena_batch)
    Athena(dataPath, measure, sub, loc)


function axes3_CreateFcn(hObject, eventdata, handles)