%% Athena_history_update
% This function updates the history of the command used by the toolbox in
% guided mode.
%
% Athena_history_update(Athena_command, check_first)
%
% Input:
%   Athena_command is the executed call, with the used parameters
%   check_first has to be 1 to check if the history variable already exists
%       in the base workspace and, if it does not exist, to create it as an
%       empty cell array (0 by default)


function Athena_history_update(Athena_command, check_first)
    if nargin == 1
        check_first = 0;
    end
    
    if check_first == 1
        all_var = evalin('base', 'whos'); 
        if not(ismember('Athena_history',{all_var(:).name}))
            assignin('base', 'Athena_history', Athena_command);
        end
    else
        history_check = evalin('base', "whos('Athena_history')"); 
        dim = max(history_check.size);
        Athena_history = strcat('Athena_history{',string(dim+1),'}=', ...
            strcat('"', Athena_command, '"'));
        evalin('base', Athena_history);
    end
end