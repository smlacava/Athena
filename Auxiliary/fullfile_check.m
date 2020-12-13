%% fullfile_check
% This function is used to manage the path to a file, with respect to the
% operative system.
%
% filename = fullfile_check(filename)
%
% Input:
%   filename is the name of the file with its path
%
% Output:
%   filename is the name of the file with its sanitized path


function filename = fullfile_check(filename)
	os = computer;
    if not(strcmp(os, 'PCWIN64'))
        filename = char(filename);
        if not(strcmpi(filename(1), filesep))
            filename = strcat(filesep, filename);
        end
    end
    filename = string(filename);
end