function [strOUT]=string_check(dataIN)
    if iscell(dataIN) || ischar(dataIN)
        strOUT=string(dataIN);
    else 
        strOUT=dataIN;
    end
end