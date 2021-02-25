%% version_info
% This function shows information about the local toolbox version and
% checks if there are new remote versions (in this case, the user can also 
% automatically download the updated version).
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
        text = fileread(strcat(limit_path(mfilename('fullpath'), ...
            'Auxiliary'), 'version.txt'));
    catch
        disp('version file not found')
        return
    end
    
    disp(' ')
    disp('Local version:')
    disp(text)
    
    if connection_check() == 0
        return;
    end
    
    try
        disp(' ')
        data = webread('https://github.com/smlacava/Athena/wiki/Version');
        data = split(data, '<div class="markdown-body">');
        data = split(data{2}, '<p>');
        data = split(data{2}, '</p>');
        remote_version = data{1};
        disp('Remote version:')
        disp(remote_version)
        disp(' ')
        if strcmpi(text, remote_version)
            disp('No new available version')
        else
            current = split(text(2:end), '.');
            remote = split(remote_version(2:end), '.');
            check = 0;
            for sub = 1:length(remote)
                if str2double(remote{sub}) < str2double(current{sub})
                    break;
                end
                if str2double(remote{sub}) > str2double(current{sub})
                    disp('New available version')
                    if strcmpi(user_decision(...
                            'Do you want to download the new version?', ...
                            'New version detected'), 'yes')
                        try
                            !git pull https://github.com/smlacava/Athena/
                            new_version = 1;
                        catch
                            new_version = 0;
                            disp('Git not found')
                            disp('You can download it manually at https://github.com/smlacava/Athena')
                            disp('Otherwise, you can continue to use the previous version')
                        end
                    end
                    check = 1;
                    break;
                end
            end
            if check == 0
                disp('No new available version')
            end
        end
    catch
    end
    disp(" ")
end