%% load_classification_data
% This function load classification data table for classification
%
% data = load_classification_data(data)
%
% input:
%   data is the name of the file which contains the data table, the study
%       folder or the data table itself
%
% output:
%   data is the data table


function data = load_classification_data(data)
    if not(istable(data)) && (ischar(data) || isstring(data))
        try
            data = load_data(strcat(path_check(strcat(path_check(data), ...
                'Classification')), 'Classification_Data.mat'));
        catch
            try
                data = load_data(data);
            catch
                problem('Data is not in the right format (table or file path)')
                data = [];
                return;
            end
        end
    end
    if not(istable(data))
        problem('Data is not usable by classification process')
        data = [];
        return;
    end
end