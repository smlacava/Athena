function [data]=load_data(dataFile)
    if contains(dataFile,'.mat')
        data=load(dataFile);
        data=struct2cell(data);
        data=data{1};
    elseif contains(dataFile,'.xlsx')
        data=readtable(dataFile,'ReadVariableNames',false);
        data=table2cell(data);
    end
end
    
