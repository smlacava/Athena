function [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, ...
    nLoc, nBands, analysis, sub_group] = correlation_setting(handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Correlations');
    cd(char(funDir{1}));
    addpath 'Auxiliary'

    bg_color = [1 1 1];
    im = imread('untitled3.png');
    dataPath = strcat(path_check(get(handles.aux_dataPath, 'String')), ...
        path_check(get(handles.aux_measure, 'String')));
    if not(exist(dataPath, 'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    
    cons = [0 1];
    cons_selected = [get(handles.minCons, 'Value'), ...
        get(handles.maxCons, 'Value')];
    cons(cons_selected == 0) = [];
    
    an_selected = [get(handles.asy_button, 'Value'), ...
        get(handles.tot_button, 'Value'), ...
        get(handles.glob_button, 'Value'), ...
        get(handles.areas_button, 'Value')];
    an_paths = {'Asymmetry', 'Total', 'Global', 'Areas'};
    analysis = an_paths(an_selected == 1);
    
    sub_selected = [get(handles.HC, 'Value'), get(handles.PAT, 'Value')];
    sub_types = {'First.mat', 'Second.mat'};
    sub_group = sub_types(sub_selected == 1);
    Subjects = load_data(get(handles.aux_sub, 'String'));
    sub_list = {};
    sub_functions = {@(x)not(patient_check(x)) @(x)patient_check(x)};
    sub_fun = sub_functions{sub_selected == 1};
    for k = 1:length(Subjects)
        if sub_fun(Subjects(k, end))
            sub_list = [sub_list; char_check(string(Subjects(k, 1)))];
        end
    end
    
    [data, ~, locs] = load_data(char_check(strcat(dataPath, ...
        path_check('Epmean'), path_check(analysis), sub_group)));
    
    nSub = size(data, 1);
    nLoc = length(locs);
    nBands = 1;
    if nLoc*nSub < numel(data)
        nBands = size(data, 2);
    end
    alpha = alpha_levelling(cons, nBands, nLoc);
    
    P = zeros(nLoc, nBands);
    RHO = P;
    try
        bands_names = cellstr(define_bands(dataPath, nBands)');
    catch
        bands_names = cell(nBands, 1);
        for i = 1:nBands
            bands_names{i, 1} = char_check(strcat("Band ", string(i)));
        end
    end