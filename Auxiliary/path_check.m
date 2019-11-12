%% path_check
% This function checks the absence of the final separator in the path and
% adds the correct separator based on the operating system used.
% 
% outPath = path_check(inPath)
%
% input:
%   inPath is the path to check
%
% output:
%   outPath is the corrected path

function outPath = path_check(inPath)
    if iscell(inPath)
        inPath = inPath{1};
    end
    inPath = char(inPath);
    if strcmp(inPath(end), '\') || strcmp(inPath(end), '/')
        outPath = char(inPath);
    else
        os = computer;
        if strcmp(os, 'PCWIN64')
            outPath = char(strcat(inPath, '\'));
        else
            outPath = char(strcat(inPath, '/'));
        end
    end
end