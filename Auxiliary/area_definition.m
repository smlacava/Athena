%% area_definition
% This function is used to define the locations related to a specific
% measure which have been studied in a specific area.
%
% locations = area_definition(handles, meas_handle, area_handle)
%
% Input:
%   handles are the handles of the graphic object
%   meas_handle is the handle related to the measure
%   area_handle is the handle related to the area
%
% Output:
%   locations is the list of locations

function locations = area_definition(handles, meas_handle, area_handle)
    dataPath = get(handles.dataPath_text, 'String');
    measures_list = get(meas_handle, 'String');
    if iscell(measures_list)
        measure = measures_list(get(meas_handle, 'Value'));
    else
        measure = measures_list;
    end
    areas_list = get(area_handle, 'String');
    area = areas_list(get(area_handle, 'Value'));
    if strcmpi(area, 'Channels')
        area = "Total";
    end
    if contains(measure, '-')
         aux_meas = split(measure, '-');
         [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
            path_check(aux_meas(1)), path_check('Network'), ...
            path_check(aux_meas(end)), path_check(area), 'Second.mat'));
    else
        [~, ~, locations] = load_data(strcat(path_check(dataPath), ...
            path_check(measure), path_check('Epmean'), path_check(area),...
            'Second.mat'));
    end
end