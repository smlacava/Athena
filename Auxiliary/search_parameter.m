%% search_parameter
% This function is used to obtain the value of a name-value pairs array
%
% value = search_parameter(parameters, field)
%
% input:
%   parameters is the cell array which contain the name-value pairs
%   field is the name of the value
%
% output:
%   value is the parameter's value


function value = search_parameter(parameters, field)
    searchparam = cellfun(@(x)isequal(x, field), parameters);
    [r, c] = find(searchparam);
    if isempty(r)
        searchparam = cellfun(@(x)isequal(x, string(field)), parameters);
        [r, c] = find(searchparam);
    end
    if isempty(r)
        searchparam = cellfun(@(x)isequal(x, ...
            string(strcat(field, '='))), parameters);
        [r, c] = find(searchparam);
    end
    if isempty(r)
        searchparam = cellfun(@(x)isequal(x, ...
            char_check(strcat(field, '='))), parameters);
        [r, c] = find(searchparam);
    end
    if isempty(r)
        value = [];
    else
        value = parameters{max(r, c)+1};
    end
    if not(iscell(value)) && sum(isnan(value))
        value = [];
    end
end