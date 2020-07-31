%% choose_filter
% This function allows to choose a custom filtering function contained in a
% file with the name of the function itself
%
% filter_file = choose_filter()
%
% Output:
%   filter_file is the name of the file which contains the filtering
%       function (if the path to the file is not inserted, then it is
%       necessary to add the related folder to the search path through the 
%       MATLAB environment before to use the filter)


function filter_file = choose_filter(filter_file)
    if nargin == 0
        filter_file = 'athena_filter';
    end
    msg = 'Do you want to use a custom filter instead of the default one?';
    title = 'Choose the filter';
    if strcmpi(user_decision(msg, title), 'yes')
        msg = 'Select the file which contains the filtering function';
        title = 'Choose the filter';
        filter_file = file_asking(filter_file, title, msg);
        if contains(filter_file, filesep)
            aux_answer = split(filter_file, filesep);
            filter_file = aux_answer{end};
            path = '';
            for i = 1:length(aux_answer)-1
                path = strcat(path, aux_answer{i}, filesep);
            end
            addpath(path);
        end
        filter_file = strtok(filter_file, '.');
    end
end
