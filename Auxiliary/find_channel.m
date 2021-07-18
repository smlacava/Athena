%% find_channel
% This function retrieves the channel coordinates.
%
% channel = find_channel(chanlocs, label)
%
% Input:
%   chanlocs is a structure containing information about all the channels
%   label is the name of the channel which has to be found
%
% Output:
%   channel is a single-element structure providing information about the
%       required channel

function channel = find_channel(chanlocs, label)
    channel = [];
    for i = 1:length(chanlocs)
        if strcmpi(chanlocs(i).labels, label)
            channel = chanlocs(i);
            break
        end
    end
end