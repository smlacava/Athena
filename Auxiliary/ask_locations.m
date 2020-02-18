%% ask_locations
% This function asks a file which contains the list of the locations of a
% time series
%
% loc_path = ask_locations(message)
%
% input:
%   message is the request message (optional)
%
% output:
%   locations is the list of the locations (it is empty if the user does
%       not select any file)


function locations = ask_locations(message)
    if nargin == 0
        message = strcat("Do you want to insert locations by file? ", ...
        "(Otherwise, each location will be set as its number in each", ...
        " signal)");
    end
    [answer] = user_decision(char_check(message), 'Locations not found');
    locations = [];
    if strcmp(answer, 'yes')
        locPath = file_asking('es. C:/User/Loc.mat', ...
            'Insert locations file', ...
            'Insert the file which contains the locations');
        if not(islogical(locPath))
            locPath = char_check(locPath);
            try
                locations = load_data(locPath);
            catch
                locations = 0;
                while locations == 0
                    problem('The file does not exist or is not usable')
                    locations = ask_locations();
                    if isempty(locations) || iscell(locations)
                        return;
                    end
                end
            end
        end
    elseif strcmp(answer, 'no')
        locations = [];
    end
end