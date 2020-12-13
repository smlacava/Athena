%% options_list
% This function is used to extract the selected option from a list of
% options contained in a structure handle.
%
% option = options_list(options_handle)
%
% Input:
%   options_handle is the structure handle containing the list of options
%
% Output:
%   option is the selected option


function option = options_list(options_handle)
    options_list = get(options_handle, 'String');
    if not(iscell(options_list))
        option = options_list;
    else
        option = options_list{get(options_handle, 'Value')};
    end
end