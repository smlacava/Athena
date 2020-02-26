function  [xData, yData, nLoc, nBands, locs] = ...
    batch_measures_correlation_settings(Measure1, Measure2, dataPath, ...
    analysis, sub_group)
    
    xData = [];
    yData = [];
    nLoc = [];
    nBands = [];
    
    data_name = strcat(dataPath, path_check(Measure1), ...
        path_check('Epmean'), path_check(char_check(analysis)), ...
        char_check(sub_group), '.mat');
    try
        [xData, ~, locs] = load_data(data_name);
    catch
        problem(strcat(Measure1, " epochs averaging of not computed"));
        return;
    end
    data_name = strcat(dataPath, path_check(Measure2), ...
    	path_check('Epmean'), path_check(char_check(analysis)), ...
        char_check(sub_group), '.mat');
    try
        yData = load_data(data_name);
    catch
        problem(strcat(Measure2, " epochs averaging of not computed"));
        return;
    end
    if size(xData, 1) ~= size(yData, 1)
        problem(strcat("There is a different number of subjects for ", ...
            "the measures (perhaps, a different subjects' file has ", ...
            "been used)"));
        return;
    end
    nLoc = size(xData);
    nLoc = nLoc(end);
    if sum(strcmp(analysis, ["global", "Asymmetry"]))
        nLoc = 1;
    end
    if length(size(xData)) == 3 || sum(strcmp(analysis, ["global", ...
            "Asymmetry"])) 
        nBands = size(xData, 2);
    else
        nBands = 1;
    end
end