function cases=define_cases(dataPath)
    dataPath=path_check(dataPath);
    cases=dir(fullfile(dataPath,'*.mat'));
    if isempty(cases)
        cases=dir(fullfile(dataPath,'*.edf'));
    end
end