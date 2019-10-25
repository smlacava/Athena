function outDir=limit_path(inDir, last)
    inDir=path_check(inDir);
    inDir=char(inDir);
    auxDir=split(inDir,inDir(end));
    outDir="";
    
    for i=1:length(auxDir)
        if strcmp(auxDir(i),last)
            break;
        else
            outDir=strcat(outDir,auxDir(i));
            outDir=path_check(outDir);
        end
    end