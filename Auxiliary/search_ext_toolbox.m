%% search_ext_toolbox
% This function is used to check if a toolbox is installed.
%
% check = search_ext_toolbox(name)
%
% input:
%   name is the name of the toolbox which has to be searched
%
% output:
%   check is 1 if the toolbox is installed (0 otherwise)


function check = search_ext_toolbox(name)
    info = ver;
    info = {info.Name};
    check = sum(cellfun(@(s) ~isempty(strfind(name, s)), info));
    if check == 0
        problem(strcat(name, " not found"))
    end
end