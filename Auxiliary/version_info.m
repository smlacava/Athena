%% version_info
% This function shows information about the local toolbox version and
% checks if there are new remote versions.
%
% new_version = version_info()
%
% Output:
%   new_version is 1 if a new version has been downloaded, 0 otherwise


function new_version = version_info()
    new_version = 0;
    disp(" ")
    disp("Athena")
    try
        text=fileread('.git/HEAD');
    catch
        disp('git folder not found')
        return
    end
    
    diary version.txt
    
    diary OFF
    
    parsed=textscan(text,'%s');
    path=parsed{1}{2};
    [pathstr, name, ext]=fileparts(path);
    SHA1text=fileread(fullfile(['.git/' pathstr],[name ext]));
    
    try
        !git describe --tags --abbrev=0
        disp(' ')
        disp('Local commit hash:')
        disp(SHA1text(1:end-1))
        disp(' ')
        disp('Remote commit hash:')
    catch
    end
    
    try
        diary ON
        !git ls-remote https://github.com/smlacava/Athena/
        disp(' ')
        diary OFF
        auxID = fopen('version.txt', 'r');
        fseek(auxID, 0, 'bof');
        while ~feof(auxID)
            prop = fgetl(auxID);
            if contains(prop, 'refs/heads/master')
                SHA1remote = split(prop);
                SHA1remote = SHA1remote{1};
                break;
            end
        end
        fclose(auxID);
        if strcmpi(SHA1text, SHA1remote) || ...
               strcmpi(SHA1text(1:end-1), SHA1remote)
            disp('No new available version')
        else
            disp('New available version')
            if strcmpi(user_decision(...
                    'Do you want to download the new version?', ...
                    'New version detected'), 'yes')
                !git fetch https://github.com/smlacava/Athena/
                new_version = 1;
            end
        end
    catch
        diary OFF
    end
    delete version.txt
    disp(" ")
end
