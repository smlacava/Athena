%% Athena_save_figures
% This function is used to ask the user if the figure (or the figures) has
% to be saved and, in this case, in which format (jpg or mat).
%
% [save_check, format] = Athena_save_figures(title, message)
%
% Input:
%   title is the first asking interface title ('Save figures' by default)
%   message is the message displayed in the first interface (''Do you want 
%       to save the resulting figures?' by default)
%
% Output:
%   save_check is 1 if the user wants to save the figure (0 otherwise)
%   format is the format decided by the user (.mat or .jpg)


function [save_check, format] = Athena_save_figures(title, message)
    if nargin < 1
        title = 'Saving figures';
    end
    if nargin < 2
        message = 'Do you want to save the resulting figures?';
    end
    save_check = strcmp(user_decision(message, title), 'yes');
    format = '.fig';
    if save_check == 1
        if strcmp('yes', user_decision(...
            'Do you want to save in .jpg format (.fig otherwise)', ...
            'Image format'))
            format = '.jpg';
        end
    end
end