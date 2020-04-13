%% batch_scatter
% This function is used in the batch study to show the scatter plot of two
% measures with different parameters
%
% batch_scatter(parameters)
%
% input:
%   parameters is the cell array which contains the pairs name-value for
%       each parameter used in the batch study


function batch_scatter(parameters)
    dataPath = search_parameter(parameters, 'dataPath');
    measure1 = search_parameter(parameters, 'Scatter_Measure1');
    measure2 = search_parameter(parameters, 'Scatter_Measure2');
    
    band1 = search_parameter(parameters, 'Scatter_Band1');
    band2 = search_parameter(parameters, 'Scatter_Band2');
    
    location1 = search_parameter(parameters, 'Scatter_Location1');
    location2 = search_parameter(parameters, 'Scatter_Location2');
    
    [area1, check1] = batch_check_area(location1);
    [area2, check2] = batch_check_area(location2);
    
    measure1_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure1), path_check('Epmean'), area1));
    measure2_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure2), path_check('Epmean'), area2));
    
    [PAT1, ~, locs1] = load_data(strcat(measure1_path, 'PAT.mat'));
    HC1 = load_data(strcat(measure1_path, 'HC.mat'));
    [PAT2, ~, locs2] = load_data(strcat(measure2_path, 'PAT.mat'));
    HC2 = load_data(strcat(measure2_path, 'HC.mat'));
    
    if check1 == 0
        idx_loc1 = 1;
    else
        for i = 1:length(locs1)
            if strcmpi(locs1{i}, location1)
                idx_loc1 = i;
                break;
            end
        end
    end
    if check2 == 0
        idx_loc2 = 1;
    else
        for i = 1:length(locs2)
            if strcmpi(locs2{i}, location2)
                idx_loc2 = i;
                break;
            end
        end
    end
    
    PAT1 = PAT1(:, band1, idx_loc1);
    HC1 = HC1(:, band1, idx_loc1);
    PAT2 = PAT2(:, band2, idx_loc2);
    HC2 = HC2(:, band2, idx_loc2);
    
    figure('Name', strcat(measure1, " ", location1, " Band ", ...
        string(band1), " - ", measure2, " ", location2, " Band ", ...
        string(band2)), 'NumberTitle', 'off', 'ToolBar', 'none');
    set(gcf, 'color', [0.67 0.98 0.92])
    scatter(HC1, HC2, 'b')
    hold on
    scatter(PAT1, PAT2, 'r')
    legend('group 0', 'group 1')
    xlabel(strcat(measure1, " ", location1, " Band ", string(band1)))
    ylabel(strcat(measure2, " ", location2, " Band ", string(band2)))
end