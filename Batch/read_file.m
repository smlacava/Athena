function [dataPath, fs, cf, epNum, epTime, tStart, totBand, measure, ...
    Subjects, locations, Index, MeasureExtraction, EpochsAverage, ...
    EpochsAnalysis, IndexCorrelation, StatisticalAnalysis, ...
    MeasuresCorrelation, ClassificationData, Group_IC, Areas_IC, ...
    Conservativeness_IC, Areas_EA, Areas_SA, Conservativeness_SA, ...
    Measure1, Measure2, Areas_MC, Group_MC, MergingMeasures, ...
    MergingAreas, Subject]=read_file(dataFile)

    dataPath=[];
    fs=[];
    cf=[];
    epNum=[]; 
    epTime=[];
    tStart=[];
    totBand=[];
    measure=[];
    Subjects=[];
    locations=[];
    Index=[];
    MeasureExtraction=[];
    EpochsAverage=[];
    EpochsAnalysis=[];
    IndexCorrelation=[];
    StatisticalAnalysis=[];
    MeasuresCorrelation=[];
    ClassificationData=[];
    Group_IC=[];
    Areas_IC=[];
    Conservativeness_IC=[];
    Areas_EA=[];
    Areas_SA=[];
    Conservativeness_SA=[];
    Measure1=[];
    Measure2=[];
    Areas_MC=[];
    Group_MC=[];
    MergingMeasures=[];
    MergingAreas=[];
    Subject=[];

    auxID=fopen(dataFile,'r');
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        proper=fgetl(auxID);
        if contains(proper,'dataPath=')
            dataPath=split(proper,'=');
            dataPath=dataPath{2};
        elseif contains(proper,'fs=')
            fs=split(proper,'=');
            fs=str2double(fs{2});
        elseif contains(proper,'cf=')
            cf=split(proper,'=');
            cf=str2double(split(cf{2}));
            cf=cf(1:end-1);
        elseif contains(proper,'epNum=')
            epNum=split(proper,'=');
            epNum=str2double(epNum{2});
        elseif contains(proper,'epTime=')
            epTime=split(proper,'=');
            epTime=str2double(epTime{2});
        elseif contains(proper,'tStart=')
            tStart=split(proper,'=');
            tStart=str2double(tStart{2});    
        elseif contains(proper,'totBand=')
            totBand=split(proper,'=');
            totBand=str2double(split(totBand{2}));
        elseif contains(proper,'measure=')
            measure=split(proper,'=');
            measure=measure{2}; 
        elseif contains(proper,'Subjects=')
            Subjects=split(proper,'=');
            Subjects=Subjects{2};
        elseif contains(proper,'Locations=')
            locations=split(proper,'=');
            locations=locations{2};
        elseif contains(proper,'Index=')
            Index=split(proper,'=');
            Index=Index{2};
        elseif contains(proper,'MeasureExtraction=')
            MeasureExtraction=split(proper,'=');
            MeasureExtraction=MeasureExtraction{2};
        elseif contains(proper,'EpochsAverage=')
            EpochsAverage=split(proper,'=');
            EpochsAverage=EpochsAverage{2};
        elseif contains(proper,'IndexCorrelation=')
            IndexCorrelation=split(proper,'=');
            IndexCorrelation=IndexCorrelation{2};
        elseif contains(proper,'EpochsAnalysis=')
            EpochsAnalysis=split(proper,'=');
            EpochsAnalysis=EpochsAnalysis{2};
        elseif contains(proper,'StatisticalAnalysis=')
            StatisticalAnalysis=split(proper,'=');
            StatisticalAnalysis=StatisticalAnalysis{2};
        elseif contains(proper,'MeasuresCorrelation=')
            MeasuresCorrelation=split(proper,'=');
            MeasuresCorrelation=MeasuresCorrelation{2};
        elseif contains(proper,'ClassificationData=')
            ClassificationData=split(proper,'=');
            ClassificationData=ClassificationData{2};
        elseif contains(proper,'Group_IC=')
            Group_IC=split(proper,'=');
            Group_IC=split(Group_IC{2});
        elseif contains(proper,'Areas_IC=')
            Areas_IC=split(proper,'=');
            Areas_IC=split(Areas_IC{2}); 
        elseif contains(proper,'Conservativeness_IC=')
            Conservativeness_IC=split(proper,'=');
            Conservativeness_IC=cons_check(Conservativeness_IC{2});   
        elseif contains(proper,'Areas_EA=')
            Areas_EA=split(proper,'=');
            Areas_EA=split(Areas_EA{2}); 
        elseif contains(proper,'Areas_SA=')
            Areas_SA=split(proper,'=');
            Areas_SA=split(Areas_SA{2}); 
        elseif contains(proper,'Conservativeness_SA=')
            Conservativeness_SA=split(proper,'=');
            Conservativeness_SA=cons_check(Conservativeness_SA{2});   
        elseif contains(proper,'Measure1=')
            Measure1=split(proper,'=');
            Measure1=Measure1{2}; 
        elseif contains(proper,'Measure2=')
            Measure2=split(proper,'=');
            Measure2=Measure2{2};
        elseif contains(proper,'Areas_MC=')
            Areas_MC=split(proper,'=');
            Areas_MC=split(Areas_MC{2});
        elseif contains(proper,'Group_MC=')
            Group_MC=split(proper,'=');
            Group_MC=split(Group_MC{2}); 
        elseif contains(proper,'MergingMeasures=')
            MergingMeasures=split(proper,'=');
            MergingMeasures=split(MergingMeasures{2});
        elseif contains(proper,'MergingAreas=')
            MergingAreas=split(proper,'=');
            MergingAreas=split(MergingAreas{2}); 
        elseif contains(proper,'Subject=')
            Subject=split(proper,'=');
            Subject=Subject{2};
        end
    end
    fclose(auxID);
end