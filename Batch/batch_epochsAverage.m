function batch_epochsAverage(dataPath, type, subjects)
    if exist('auxiliary.txt', 'file')
        auxID = fopen('auxiliary.txt', 'a+');
    elseif exist(strcat(dataPath, 'auxiliary.txt'), 'file')
        auxID = fopen(strcat(dataPath, 'auxiliary.txt'), 'a+');
    end
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        proper = fgetl(auxID);
        if contains(proper, 'type')
            type = split(proper, '=');
            type = type{2};
        end
        if contains(proper, 'Epmean')
            EMflag = 1;
        end
    end
    epmean_and_manage(dataPath, type, subjects);
    PAT = strcat(dataPath, 'PAT_em.mat');
    HC = strcat(dataPath, 'HC_em.mat');
    fprintf(auxID, '\nEpmean=true');
    fprintf(auxID, '\nPAT=%s', PAT);
    fprintf(auxID, '\nHC=%s', HC);
    fprintf(auxID, '\nSubjects=%s', subjects);
    fclose(auxID);
end