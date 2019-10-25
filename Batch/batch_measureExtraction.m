function []=batch_measureExtraction(measure, fs, cf, epNum, epTime, ...
    dataPath, tStart, totBand)

    if strcmp(measure, "PSDr")
        PSDr(fs, cf, epNum, epTime, dataPath, tStart, totBand)
    elseif sum(strcmp(measure, ["exponent", "offset"]))
        FOOOFer(fs, cf, epNum, epTime, dataPath, tStart, measure)
    else
        connectivity(fs, cf, epNum, epTime, dataPath, tStart, measure)
    end
        
    auxID=fopen('auxiliary.txt','w');
    fprintf(auxID, 'dataPath=%s',dataPath);
    fprintf(auxID, '\nfs=%d',fs);
    fprintf(auxID, '\ncf=');
    for i = 1:length(cf)
        fprintf(auxID, '%d ',cf(i));
    end
    fprintf(auxID, '\nepNum=%d',epNum);
    fprintf(auxID, '\nepTime=%d',epTime);
    fprintf(auxID, '\ntStart=%d',tStart);
    fprintf(auxID, '\ntotBand=%d %d',totBand(1), totBand(2));
    fprintf(auxID, '\nmeasure=%s',measure);
    fclose(auxID);
end