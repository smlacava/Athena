%% sort_chanlocs
% This function returns the channel locations structure ordered as the
% locations cell array.
% 
% chanlocs = sort_chanlocs(chanlocs, locations)
%
% Input:
%   chanlocs is the structure related to the channels locations
%   locations is the cell array containing the list of channels
%
% Output:
%   chanlocs is the ordered channels locations structure

function chanlocs = sort_chanlocs(chanlocs, locations)
    L = length(locations);
    N = length(chanlocs);
    idx = [];
    for i = 1:L
        for j = 1:N
            if strcmpi(normalize_name(chanlocs(j).labels), ...
                    normalize_name(locations{i}))
                idx = [idx, j];
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