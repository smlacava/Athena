function epochs_analysis(dataPath, name, anType, measure, epochs, bands, loc)
    cases=dir(fullfile(strcat(dataPath,'*.mat')));
    for i=1:length(cases)
        if contains(cases(i).name,name)
            dataFile=strcat(dataPath,cases(i).name);
            break;
        end
    end
    data=load_data(dataFile);
    loc=load_data(loc);
    
    if strcmp(anType,'asymmetry')
        [RightLoc, LeftLoc]=asymmetry_manager(loc);
        locList="Asymmetry";
        if (strcmp(measure,'PSDr') || strcmp(measure,'offset') || strcmp(measure,'exponent'))
            epan_asy(data, epochs, bands, measure, name, RightLoc, LeftLoc)
        else
            epan_asy_conn(data, epochs, bands, measure, name, RightLoc, LeftLoc)
        end
    elseif strcmp(anType, 'global')
        if (strcmp(measure,'PSDr') || strcmp(measure,'offset') || strcmp(measure,'exponent'))
            epan_glob(data, epochs, bands, measure, name)
        else
            epan_glob_conn(data, epochs, bands, measure, name)
        end
    elseif strcmp(anType,'areas')
        [CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc]=areas_manager(loc);
        if (strcmp(measure,'PSDr') || strcmp(measure,'offset') || strcmp(measure,'exponent'))
            epan_areas(data, epochs, bands, measure, name, CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc)
        else
            epan_areas_conn(data, epochs, bands, measure, name, CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc)
        end
    else
        if (strcmp(measure,'PSDr') || strcmp(measure,'offset') || strcmp(measure,'exponent'))
            epan_tot(data, epochs, bands, measure, name, loc)
        else
            epan_tot_conn(data, epochs, bands, measure, name, loc)
        end
    end
            
        