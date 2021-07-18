%% scatter_analysis
% This function shows the scatter plot between two different measures,
% choosing for each one the location and the frequency band to analyze.
%
% scatter_analysis(dataPath, first_measure, second_measure, first_area, ...
%     second_area, first_band_number, second_band_number, ...
%     first_location_number, second_location_number, ...
%     first_location_name, second_location_name, first_band_name, ...
%     second_band_name, sub_types)
%
% Input:
%   dataPath is the main directory of the study
%   first_measure is the name of the first measure
%   second_measure is the name of the second measure
%   first_area is the name of the first spatial subdivision to analyze
%       (Total, Global, Asymmetry or Areas)
%   second_area is the name of the second spatial subdivision to analyze
%       (Total, Global, Asymmetry or Areas)
%   first_band_number is the number of the frequency band to analyze in the
%       first measure
%   second_band_number is the number of the frequency band to analyze in 
%       the second measure
%   first_location_number is the number of the location to analyze in the
%       first measure
%   second_location_number is the number of the location to analyze in the
%       second measure
%   first_location_name is the name of the location to analyze in the
%       first measure (optional)
%   second_location_name is the name of the location to analyze in the
%       second measure (optional)
%   first_band_name is the name of the frequency band to analyze in the
%       first measure (optional)
%   second_band_name is the name of the frequency band to analyze in 
%       the second measure (optional)
%   sub_types is the cell array which contains the names of the subjects'
%       group analyzed


function scatter_analysis(dataPath, first_measure, second_measure, ...
    first_area, second_area, first_band_number, second_band_number, ...
    first_location_number, second_location_number, first_location_name, ...
    second_location_name, first_band_name, second_band_name, sub_types)
    
    if nargin < 10 && sum(contains(first_area, ...
            {'Asymmetry', 'Global'})) == 0
        first_location_name = '';
    elseif sum(contains(first_area, {'Asymmetry', 'Global'})) > 0
        first_location_name = first_area;
    end
    if nargin < 11 && sum(contains(second_area, ...
            {'Asymmetry', 'Global'})) == 0
        second_location_name = '';
    elseif sum(contains(second_area, {'Asymmetry', 'Global'})) > 0
        second_location_name = second_area;
    end
    if nargin < 12
        second_band_name = string(first_band_number);
    end
    if nargin < 13
        second_band_name = '';
    end
    
    x_name = strcat(first_measure, " ", first_location_name, " ", ...
            first_band_name);
    y_name = strcat(second_measure, " ", second_location_name, " ", ...
        second_band_name);
    title = strcat(x_name, " - ", y_name);
    
    measure1_path = path_check(strcat(path_check(dataPath), ...
        path_check(first_measure), path_check('Epmean'), first_area));
    measure2_path = path_check(strcat(path_check(dataPath), ...
        path_check(second_measure), path_check('Epmean'), second_area));
    
    check1 = 0;
    check2 = 0;
    if sum(contains(first_area, {'Asymmetry', 'Global'})) > 0
        check1 = 1;
    end
    if sum(contains(second_area, {'Asymmetry', 'Global'})) > 0
        check2 = 1;
    end
    
    [PAT1, ~, locs1] = load_data(strcat(measure1_path, 'Second.mat'));
    HC1 = load_data(strcat(measure1_path, 'First.mat'));
    [PAT2, ~, locs2] = load_data(strcat(measure2_path, 'Second.mat'));
    HC2 = load_data(strcat(measure2_path, 'First.mat'));
    
    if check1 == 0
        first_location_number = 1;
    end
    if check2 == 0
        second_location_number = 1;
    end
    
    PAT1 = PAT1(:, first_band_number, first_location_number);
    HC1 = HC1(:, first_band_number, first_location_number);
    PAT2 = PAT2(:, second_band_number, second_location_number);
    HC2 = HC2(:, second_band_number, second_location_number);
    
    figure('Name', title, 'NumberTitle', 'off', 'ToolBar', 'none');
    set(gcf, 'color', [1 1 1])
    scatter(HC1, HC2, 'b')
    hold on
    scatter(PAT1, PAT2, 'r')
    if nargin >= 14
        legend(sub_types)
    end
    xlabel(x_name)
    ylabel(y_name)
end