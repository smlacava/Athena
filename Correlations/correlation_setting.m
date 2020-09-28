%% correlation_setting
% This function extract the parameters used for a following correlation
% computation, through the values inserted in the related toolbox interface
% or through the parameters used as arguments
%
% [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, ...
%    nLoc, nBands, analysis, sub_group] = ...
%    correlation_setting_args(handles, varargin)
% 
% Input:
%   handles is the structure which contains all the handles related to the
%       toolbox interface, or the first used parameter (the main folder
%       of the study)
%   varargin is the cell array, which contains in order, the list of the 
%       two measures, the conservativeness level (1 for maximum, 0 for 
%       minimum), the analysis (Asymmetry, 
%       Global, etc.), the names of the two subject groups, the flag of the
%       first group (1 to choose the first group, 0 otherwise), the flag of
%       the second group, and the file which contains the list of all the
%       subject of the study (varargin is considered for studies without
%       the graphic interface)
%
% Output:
%   data is the data matrix
%   sub_list is the list of subjects considered in the correlation analysis
%   alpha is the alpha level evaluated in the correlation analysis
%   bg_color is the background color of the following resulting figures
%   locs is the list of locations to consider in the correlation analysis
%   bands_names is the list of frequency bands names
%   P is the p-values matrix which will be feed in the correlation analysis
%   RHO is the RHOs matrix which will be feed in the correlation analysis
%   nLoc is the number of locations
%   nBands is the number of frequency bands
%   analysis is the spatial subdivision considered in the following
%       correlation analysis
%   sub_group is the name of the considered group of subjects

function [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, ...
    nLoc, nBands, analysis, sub_group] = correlation_setting(handles, ...
    varargin)

    if not(isempty(varargin))
        [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, ...
            nLoc, nBands, analysis, sub_group] = ...
            correlation_setting_args([handles, varargin]);
        return;
    end
    
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Correlations');
    cd(char(funDir{1}));
    addpath 'Auxiliary'

    bg_color = [1 1 1];
    im = imread('untitled3.png');
    try
        measures = get(handles.meas1, 'String');
        measure = measures{get(handles.meas1, 'Value')};
    catch
        measures = get(handles.meas, 'String');
        measure = measures{get(handles.meas, 'Value')};
    end
    
    an_selected = [get(handles.asy_button, 'Value'), ...
        get(handles.tot_button, 'Value'), ...
        get(handles.glob_button, 'Value'), ...
        get(handles.areas_button, 'Value')];
    an_paths = {'Asymmetry', 'Total', 'Global', 'Areas'};
    analysis = an_paths(an_selected == 1);
    
    dataPath = measurePath(get(handles.aux_dataPath, 'String'), measure,...
        analysis);
    if not(exist(dataPath, 'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    
    cons = [0 1];
    cons_selected = [get(handles.minCons, 'Value'), ...
        get(handles.maxCons, 'Value')];
    cons(cons_selected == 0) = [];
    
    sub_group_names = get(handles.sub_types, 'Data');
    sub_selected = [get(handles.HC, 'Value'), get(handles.PAT, 'Value')];
    sub_types = {'First.mat', 'Second.mat'};
    sub_group = sub_types(sub_selected == 1);
    Subjects = load_data(get(handles.aux_sub, 'String'));
    sub_list = {};
    sub_functions = {@(x)not(patient_check(x, sub_group_names(2))), ...
        @(x)patient_check(x, sub_group_names(2))};
    sub_fun = sub_functions{sub_selected == 1};
    for k = 1:length(Subjects)
        if sub_fun(Subjects(k, end))
            sub_list = [sub_list; char_check(string(Subjects(k, 1)))];
        end
    end
    
    [data, ~, locs] = load_data(char(strcat(path_check(dataPath), ...
        sub_group)));
    
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
end


%% correlation_setting_args
% This function extract the parameters used for a following correlation
% computation, through the arguments contained in the input cell array
%
% [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, ...
%    nLoc, nBands, analysis, sub_group] = correlation_setting_args(params)
% 
% Input:
%   params is the cell array, which has to contain in order the main folder
%       of the study, the list of the two measures, the conservativeness 
%       level (1 for maximum, 0 for minimum), the analysis (Asymmetry, 
%       Global, etc.), the names of the two subject groups, the flag of the
%       first group (1 to choose the first group, 0 otherwise), the flag of
%       the second group, and the file which contains the list of all the
%       subject of the study
%
% Output:
%   data is the data matrix
%   sub_list is the list of subjects considered in the correlation analysis
%   alpha is the alpha level evaluated in the correlation analysis
%   bg_color is the background color of the following resulting figures
%   locs is the list of locations to consider in the correlation analysis
%   bands_names is the list of frequency bands names
%   P is the p-values matrix which will be feed in the correlation analysis
%   RHO is the RHOs matrix which will be feed in the correlation analysis
%   nLoc is the number of locations
%   nBands is the number of frequency bands
%   analysis is the spatial subdivision considered in the following
%       correlation analysis
%   sub_group is the name of the considered group of subjects

function [data, sub_list, alpha, bg_color, locs, bands_names, P, RHO, ...
    nLoc, nBands, analysis, sub_group] = correlation_setting_args(params)

    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Correlations');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    
    dataPath = params{1};
    measure = params{2};
    cons = params{3};
    analysis = params{4};
    sub_group_names = params{5};
    first_group_check = params{6};
    second_group_check = params{7};
    sub_file = params{8};

    bg_color = [1 1 1];
    im = imread('untitled3.png');
    dataPath = strcat(path_check(dataPath), path_check(measure));
    if not(exist(dataPath, 'dir'))
        problem(strcat("Directory ", dataPath, " not found"))
        return
    end
    
    Subjects = load_data(sub_file);
    sub_selected = [first_group_check, second_group_check];
    sub_types = {'First.mat', 'Second.mat'};
    sub_group = sub_types(sub_selected == 1);
    sub_list = {};
    sub_functions = {@(x)not(patient_check(x, sub_group_names(2))), ...
        @(x)patient_check(x, sub_group_names(2))};
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
    
end