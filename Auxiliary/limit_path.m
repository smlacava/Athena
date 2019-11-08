%% limit_path
% This function returns the path in input until a selected last node
% (which will be the first excluded node).
%
% outDir = limit_path(inDir, last)
%
% input:
%   inDir is the path to be limited
%   last is the first of the excluded nodes
%
% output:
%   outDir is the limited path

function outDir = limit_path(inDir, last)
    inDir = path_check(inDir);
    auxDir = split(inDir, inDir(end));
    outDir = '';
    
    for i = 1:length(auxDir)
        if strcmp(auxDir(i), last)
            break;
        else
            outDir = strcat(outDir, auxDir(i));
            outDir = path_check(outDir);
        end
    end
end