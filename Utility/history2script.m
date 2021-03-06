%% history2script
% This function creates a ready-to-run and commented script from the
% toolbox history related to the current session.
%
% history2script(filename, commentFLAG)
%
% Input:
%   filename is the name of the file (with its path) which will be given to
%       the resulting script (history_script.m by default, the .m extension 
%       will be added if the extension of the file will not be detected)
%   commentFLAG has to be 1 in order to explain the functions through
%       comments, 0 otherwise (1 by default)

function history2script(filename, commentFLAG)
    if nargin < 1
        filename = 'history_script.m';
    end
    if nargin < 2
        commentFLAG = 1;
    end
    
    if not(contains(filename, '.'))
        filename = strcat(path_check(filename), 'history_script.m');
    end
    if exist(filename, 'file')
        delete(filename)
    end
    
    auxID = fopen(filename, 'w');
    history = evalin('base', 'Athena_history');
    L = length(history);
    previous = '';
    fseek(auxID, 0, 'bof');
    for i = 1:L
        input_check = 0;
        aux_history = split(history{i}, '(');
        aux_history = split(aux_history(1), " ");
        aux_history = split(aux_history(end), "=");
        aux_history = aux_history(end);
        
        if commentFLAG == 1 && not(strcmp(previous, aux_history))
            commandID = fopen(strcat(aux_history,'.m'), 'r');
            fseek(commandID, 0, 'bof');
            while input_check == 0
                description = fgetl(commandID);
                if contains(description, 'Input:') || ...
                        contains(description, 'input')
                    input_check = 1;
                    fclose(commandID);
                else
                    fprintf(auxID, '%s\n', description);
                end
            end
            previous = aux_history;
        end
        
        fprintf(auxID, '\n%s\n\n\n', history{i});
    end
    fclose(auxID);
end