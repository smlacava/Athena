%% mtt_glob_conn
% This function computes the Wicox's analysis between global connectivity
% measures of 2 different groups.
% 
% [P, Psig, data, dataSig] = mtt_glob_conn(PAT, HC, cons)
%
% input:
%   PAT is the name of the file (with its directory) which contains the
%   	matrix subjects*bands*locations of the patients group
%   HC is the name of the file (with its directory) which contains the
%       matrix subjects*bands*locations of the healthy controls group
%   cons is the level of conservativeness which determinates the
%       significativity of any difference (0=no conservativeness [default],
%       1=max conservativeness)
%
% output:
%   P is the p-value matrix
%   Psig is the significativity matrix
%   data is the output matrix subjects*(bands*locations) useful
%       for external analysis (for example, other statistical analysis,
%       correlation analysis or classification)
%   dataSig is the matrix related to the measure of each subject in 
%       significant comparisons


function [P, Psig, data, dataSig]=mtt_glob_conn(PAT, HC, cons)
    
    nLoc = size(PAT, 3);
    dataSig = [];
    
    if length(size(HC)) == 4
        nBands = size(HC, 2);
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        HC_total = zeros(nHC, nBands);
        PAT_total = zeros(nPAT, nBands);
        
        HC_total(:, :) = sum(HC(:, :, :, :), [3 4])/(nLoc*nLoc-nLoc);
        PAT_total(:, :) = sum(PAT(:, :, :, :), [3 4])/(nLoc*nLoc-nLoc);
        
        data = zeros(nHC+nPAT, nBands);
        Psig = [string(), string()];
        P = zeros(nBands, 1);
        alpha = alpha_levelling(cons, nBands);
        
        for i = 1:nBands
        	data(1:nHC, i) = HC_total(:, i);
            data(nHC+1:end, i) = PAT_total(:, i);
            P(i, 1) = ranksum(data(1:nHC, i), data(nHC+1:end, i));            
            if P(i, 1) < alpha
                diff = mean(data(1:nHC, i))-mean(data(nHC+1:end, i));
                dataSig = [dataSig data(:, i)];
                if diff > 0
                    Psig = [Psig; strcat('Band', string(i)), ...
                        "major in HC"];
                else
                    Psig = [Psig; strcat('Band',string(i)), ...
                        "major in PAT"];
                end   
            end
        end
        Psig(1, :) = [];
    else
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        HC_total = zeros(nHC, 1);
        PAT_total = zeros(nPAT, 1);
        
        HC_total(:, 1) = sum(HC(:, :, :), [2 3])/(nLoc*nLoc-nLoc);
        PAT_total(:, 1) = sum(PAT(:, :, :), [2 3])/(nLoc*nLoc-nLoc);
        
        data = zeros(nHC+nPAT, 1);
        Psig = string();
        
        alpha = alpha_levelling(cons);
        data(1:nHC, 1) = HC_total(:, 1);
        data(nHC+1:end, 1) = PAT_total(:, 1);
        P = ranksum(data(1:nHC, 1), data(nHC+1:end, 1));
            
        if P < alpha
            diff = mean(data(1:nHC, 1))-mean(data(nHC+1:end, 1));
            dataSig = [dataSig data(:, 1)];    
            if diff > 0
                Psig = "major in HC";
            else
                Psig = "major in PAT";
            end
        end
    end
end