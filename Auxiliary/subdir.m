%% subDir
% This function check if a subdirectory already exists and, if it does not
% exist, it will be created and returned as a string
%
% subDir = subdir(inDir, relativeDir)
%
% input:
%   inDir is the directory which would contain the subdirectory
%   relativeDir is the relative path of the subdirectory
%
% output:
%   subDir is the absolute path of the subdirectory


function subDir = subdir(inDir, relativeDir)
    subDir = strcat(path_check(inDir), relativeDir);
    if not(exist(subDir, 'dir'))
        mkdir(subDir);
    end
end

