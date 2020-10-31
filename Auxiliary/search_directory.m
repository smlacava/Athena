%% search_directory
% This function returns the fullpath related to a directory or a file (in
% this case, it is necessary to insert also the related extension).
%
% resDir = search_directory(Dir, initDir)
%
% Input:
%   Dir is the name of the directory (or the file) which has to be searched
%   initDir is the name of the initial directory in which the directory or
%       the file have to be searched (optional)
%
% Output:
%   resDir is the fullname of the directory or the file (empty array if not
%       present)

function resDir = search_directory(Dir, initialDir)
    resDir = [];
    
    if nargin == 2
        if exist(initialDir, 'dir')
            resDir = find_directory(Dir, initialDir);
            if not(isempty(resDir))
                return
            end
        end
    end
    
    D = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for i = 1:length(D)
        auxD = strcat(D(i), ':');
        if exist(auxD, 'dir')
            resDir = find_directory(Dir, auxD);
            if not(isempty(resDir))
                break;
            end
        end
    end
end


%% find_directory
% This function is used to search the whished file or directory,
% recursively.
%
% resDir = find_directory(Dir, auxD)
%
% Input:
%   Dir is the name of the searched file or directory
%   auxD is the currently analyzed directory
%
% Output:
%   resDir is the fullname of the searched file or directory (empty array
%       if not present)

function resDir = find_directory(Dir, auxD)
    cases = dir(auxD);
    auxD = strcat(auxD, filesep);
    L = length(cases);
    resDir = [];
    for i = 1:L
        if contains(cases(i).name, Dir)
            resDir = strcat(auxD, Dir);
            return;
        end
    end
    for i = 1:L
        if not(contains(cases(i).name, '.'))
            resDir = find_directory(Dir, strcat(auxD, cases(i).name));
            if not(isempty(resDir)) && contains(resDir, Dir)
                return;
            end
        end
    end
end


            