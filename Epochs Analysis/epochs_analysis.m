%% epochs_analysis
% This function executes the epochs analysis of a previously extacted
% measure of a subject in a selected study area.
%
% epochs_analysis(dataPath, name, anType, measure, epochs, bands, loc)
%
% input:
%   dataPath is the directory which contains the matrix of the selected 
%       measure of every subject
%   name is the name of the subject to analyze
%   anType is the areas of the analysis (total, global, areas or asymmetry)
%   measure is the measure to analyze
%   epochs is the number of epochs
%   bands is the number of frequency bands
%   loc is the name of the file (with its path) which contains information
%       about the locations


function epochs_analysis(dataPath, name, anType, measure, epochs, ...
    bands, loc)
    dataPath = char_check(path_check(dataPath));
    measure = char_check(measure);
    if not(strcmp(dataPath(end-length(measure):end-1), measure))
        dataPath = path_check(strcat(dataPath, measure));
    end
    if strcmp(measure, 'offset') || strcmp(measure, 'exponent')
        bands = 1;
    end
    cases = define_cases(dataPath);
    locations = [];
    name = split(name, '.');
    name = name{1};
    for i = 1:length(cases)
        if contains(cases(i).name, name)
            dataFile = strcat(dataPath, cases(i).name);
            [data, ~, locations] = load_data(dataFile);
            break;
        end
    end
    if isempty(locations)
        if strcmp(loc, 'Static Text') 
            loc = ask_locations("Do you want to insert locations' file?");
        end
        if ischar(loc) && size(loc, 1) == 1
            loc = load_data(loc);
        end
        if isempty(loc)
            problem(strcat("You cannot compute the epochs analysis ", ...
                "without the list of the locations"))
            return;
        end
        if size(loc, 1) > 1
            loc = loc(:, 1);
        end
    else
        loc = locations(:, 1);
    end
       
    if strcmp(anType, 'asymmetry')
        [RightLoc, LeftLoc] = asymmetry_manager(loc);
        if (strcmp(measure, 'PSDr') || strcmp(measure, 'offset') ...
                || strcmp(measure, 'exponent'))
            epan_asy(data, epochs, bands, measure, name, RightLoc, LeftLoc)
        else
            epan_asy_conn(data, epochs, bands, measure, name, RightLoc, ...
                LeftLoc)
        end
    elseif strcmp(anType, 'global')
        if (strcmp(measure, 'PSDr') || strcmp(measure, 'offset') ...
                || strcmp(measure, 'exponent'))
            epan_glob(data, epochs, bands, measure, name)
        else
            epan_glob_conn(data, epochs, bands, measure, name)
        end
    elseif strcmp(anType, 'areas')
        [CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ...
            ParietalLoc] = areas_manager(loc);
        if (strcmp(measure, 'PSDr') || strcmp(measure, 'offset') ...
                || strcmp(measure, 'exponent'))
            epan_areas(data, epochs, bands, measure, name, CentralLoc, ...
                FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc)
        else
            epan_areas_conn(data, epochs, bands, measure, name, ...
                CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ...
                ParietalLoc)
        end
    else
        if (strcmp(measure, 'PSDr') || strcmp(measure, 'offset') ...
                || strcmp(measure, 'exponent'))
            epan_tot(data, epochs, bands, measure, name, loc)
        else
            epan_tot_conn(data, epochs, bands, measure, name, loc)
        end
    end
end