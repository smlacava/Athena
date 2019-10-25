function [consOUT]=cons_check(consIN)
    if sum(strcmp(consIN,["max", "Max", "MAX", "1"]))
        consOUT=1;
    else
        consOUT=0;
    end
end