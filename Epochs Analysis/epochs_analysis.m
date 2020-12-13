%% epochs_analysis
% This function executes the epochs analysis of a previously extacted
% measure of a subject in a selected study area.
%
% epochs_analysis(dataPath, name, anType, measure, epochs, bands, loc, ...
%         save_check, format)
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
%   save_check is 1 if the resulting figures have to be saved (0 otherwise)
%   format is the format in which the figures have to be eventually saved


function epochs_analysis(dataPath, name, anType, measure, epochs, ...
    bands, loc, save_check, format)
    dataPath = char_check(path_check(dataPath));
    measure = char_check(measure);
    if not(strcmp(dataPath(end-length(measure):end-1), measure))
        dataPath = path_check(strcat(dataPath, measure));
    end
    if strcmp(measure, 'offset') || strcmp(measure, 'exponent')
        bands = 1;
    end
    if nargin < 8
        save_check = 0;
        format = '';
    end
    bands = define_bands(dataPath, bands);
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
    
    conn_measures = Athena_measures_list(0, 0, 1, 0);
    connCHECK = 0;
    for i = 1:length(conn_measures)
        if strcmpi(conn_measures(i), measure)
            connCHECK = 1;
            break;
        end
    end
    dataPath = limit_path(dataPath, measure);
    if strcmp(anType, 'asymmetry')
        [RightLoc, LeftLoc] = asymmetry_manager(loc);
        if connCHECK == 0
            epan_asy(data, epochs, bands, measure, name, RightLoc, ...
                LeftLoc, save_check, format, dataPath)
        else
            epan_asy_conn(data, epochs, bands, measure, name, RightLoc, ...
                LeftLoc, save_check, format, dataPath)
        end
    elseif strcmp(anType, 'global')
        if connCHECK == 0
            epan_glob(data, epochs, bands, measure, name, ...
                save_check, format, dataPath)
        else
            epan_glob_conn(data, epochs, bands, measure, name, ...
                save_check, format, dataPath)
        end
    elseif strcmp(anType, 'areas')
        [CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ...
            ParietalLoc] = areas_manager(loc);
        if connCHECK == 0
            epan_areas(data, epochs, bands, measure, name, CentralLoc, ...
                FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, ...
                save_check, format, dataPath)
        else
            epan_areas_conn(data, epochs, bands, measure, name, ...
                CentralLoc, FrontalLoc, TemporalLoc, OccipitalLoc, ...
                ParietalLoc, save_check, format, dataPath)
        end
    else
        if connCHECK == 0
            epan_tot(data, epochs, bands, measure, name, loc, ...
                save_check, format, dataPath)
        else
            epan_tot_conn(data, epochs, bands, measure, name, loc, ...
                save_check, format, dataPath)
        end
    end
end


function bands = define_bands(dataPath, bands)
    dataFile = strcat(dataPath, 'Auxiliary.txt');
    if exist(dataFile, 'file')
        parameters = read_file(dataFile);
        cf = search_parameter(parameters, 'cf');
        if not(isempty(cf)) 
            bands = {};
            for i = 1:length(cf)-1
                bands = [bands strcat(string(cf(i)), '-', ...
                    string(cf(i+1)), " Hz")];
            end
        end
    end
end