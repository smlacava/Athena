%% connection_check
% This function checks if the Internet connection is available.
% 
% available = connection_check()
%
% Output:
%   available is 1 if the Internet connection is available, 0 otherwise.


function available = connection_check()
    if ispc
        C = evalc('!ping -n 1 www.google.com');    
    elseif isunix
        C = evalc('!ping -c 1 www.google.com');        
    end
    aux_C = split(C, ' = ');
    if length(aux_C) == 1
        available = 0;
        return;
    end
    aux_C = aux_C{4};
    available = str2double(aux_C(1)) == 0;
end