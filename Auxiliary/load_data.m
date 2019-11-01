function [data, fs]=load_data(dataFile)
    fs=[];
    if contains(dataFile,'.mat')
        data=load(dataFile);
        data=struct2cell(data);
        data=data{1};
    elseif contains(dataFile,'.xlsx')
        data=readtable(dataFile,'ReadVariableNames',false);
        data=table2cell(data);
    elseif contains(dataFile, '.edf')
        [info, data]=edfread(dataFile);
        fs=info.frequency(1);
    end
end
    
