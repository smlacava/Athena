function  [xData, yData, nLoc, nBands, locs] = ...
    batch_measures_correlation_settings(Measure1, Measure2, dataPath, ...
    analysis, sub_group)
    
    xData = [];
    yData = [];
    nLoc = [];
    nBands = [];
    
    data_name = strcat(path_check(measurePath(dataPath, Measure1, ...
        analysis)), char_check(sub_group), '.mat');
    try
        [xData, ~, locs] = load_data(data_name);
    catch
        problem(strcat(Measure1, " epochs averaging of not computed"));
        return;
    end
    data_name = strcat(path_check(measurePath(dataPath, Measure2, ...
        analysis)), char_check(sub_group), '.mat');
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
    nBands = define_nBands(xData, analysis);
end


function nBands = define_nBands(data, area)
    nBands = 1;
    if length(size(data)) == 3
        nBands = size(data, 2);
    elseif sum(strcmpi(area, {'global', 'asymmetry'}))
        nBands = size(data);
        nBands = nBands(end);
    end
    if length(size(data)) == 1
        nBands = 1;
    end
end