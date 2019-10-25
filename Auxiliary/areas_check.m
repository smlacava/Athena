function [areasOUT]=areas_check(areasIN)
    if sum(strcmp(areasIN, ["Tot", "TOT", "Total", "total", "TOTAL"]))
        areasOUT='total';
    elseif sum(strcmp(areasIN, ["Areas", "areas", "AREAS"]))
        areasOUT='areas';
    elseif sum(strcmp(areasIN, ["Asymmetry", "asymmetry", "ASYMMETRY", ...
            "ASY", "Asy", "asy"]))
        areasOUT='asymmetry';
    else
        areasOUT='global';
    end
end