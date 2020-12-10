%% match_chanlocs
% This function returns a data structure containing the only common
% channels locations.
%
% chanlocs = match_chanlocs(chanlocs, new_chanlocs)
%
% Input:
%   chanlocs is the structure related to the first channel locations
%   new_chanlocs is the structure related to the second channel locations
%
% Output:
%   chanlocs is the structure containing the only common channel locations

function chanlocs = match_chanlocs(chanlocs, new_chanlocs)
    if isempty(new_chanlocs)
        chanlocs = [];
    end
    if isempty(chanlocs)
        return;
    end
    L = length(chanlocs);
    new_L = length(new_chanlocs);
    idx = [];
    for i = 1:L
        for j = 1:new_L
            if strcmpi(normalize_name(chanlocs(i).labels), ...
                    normalize_name(new_chanlocs(j).labels))
                idx = [idx, i];
                break;
            end
        end
    end
    chanlocs = chanlocs(idx);
end


function name = normalize_name(name)
    symbols = {'_', '-'};
    for i = 1:length(symbols)
        name = strtok(name, symbols{i});
    end
end