%% cf_reader
% The cf_reader function is able to obtain a list of numbers from a string
% which contains them, separated either by commas and/or spaces.
%
% cf_list = cf_reader(cf_string)
%
% Input:
%   cf_string is the string which contains the numbers
%
% Output:
%   cf_list is the numerical array which contains the numbers


function cf_list = cf_reader(cf_string)
    space_cf = split(cf_string, ' ');
    aux_cf_list = {};
    cf_list = [];
    for i = 1:length(space_cf)
        if not(isempty(space_cf(i)))
            aux_cf = split(space_cf{i}, ',');
            for j = 1:length(aux_cf)
                if not(isnan(str2double(aux_cf(j))))
                    cf_list = [cf_list str2double(aux_cf(j))];
                end
            end
        end
    end
end
            
    