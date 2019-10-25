%% path_check
% This function checks the absence of the final separator in the path and
% adds the correct separator based on the operating system used.
% 
% outPath=path_check(inPath)
%
% input:
%   inPath is the path to check
%
% output:
%   outPath is the corrected path

function outPath=path_check(inPath)
    if iscell(inPath)
        inPath=inPath{1};
    end
    pathCheck=split(inPath,"");
    if pathCheck(end-1)=="\" || pathCheck(end-1)=="/"
        outPath=inPath;
    else
        os=computer;
        if os=='PCWIN64'
            outPath=strcat(inPath,"\");
        else
            outPath=strcat(inPath,"/");
        end
    end