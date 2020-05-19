%% create_directory
% This function checks if a directory already exists and, if it does not
% exists, creates it as a sub-folder of the absolute path
%
% directory = create_directory(absolute_path, name)
%
% input:
%   absolute_path is the parent directory
%   name is the name of the directory to create (needed if the name of the
%       directory is not already presed inside the absolute path)
%
% output:
%   directory is the name of the directory, with its absolute path


function directory = create_directory(absolute_path, name)
    if nargin == 2
        directory = strcat(path_check(absolute_path), name);
    else
        directory = absolute_path;
    end
    if not(exist(directory, 'dir'))
        mkdir(directory)
    end
end