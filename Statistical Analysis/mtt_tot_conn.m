%% mtt_tot_conn
% This function computes the Wicox's analysis between connectivity measures
% in each location of 2 different groups.
% 
% [P, Psig, data, dataSig] = mtt_tot_conn(PAT, HC, locations, cons)
%
% input:
%   PAT is the name of the file (with its directory) which contains the
%   	matrix subjects*bands*locations of the patients group
%   HC is the name of the file (with its directory) which contains the
%       matrix subjects*bands*locations of the healthy controls group
%   locations is the matrix of the locations
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

function [P, Psig, data, dataSig] = mtt_tot_conn(PAT, HC, locations, cons)
    nLoc = length(locations);
    dataSig = [];
    
    if length(size(HC)) == 4
        nBands = size(HC, 2);
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        data = zeros(nHC+nPAT, nBands, nLoc);
        Psig = [string(), string(), string()];
        P = zeros(nBands, nLoc);
        alpha = alpha_levelling(cons, nLoc, nBands);
        
        for i = 1:nBands
            for j = 1:nLoc
                data(1:nHC, i, j) = sum(HC(:, i, j, :), 4)/(nLoc-1);
                data(nHC+1:end, i, j) = sum(PAT(:, i, j, :), 4)/(nLoc-1);
                P(i, j) = ranksum(data(1:nHC, i, j), ...
                    data(nHC+1:end, i, j));            
                if P(i, j) < alpha
                    diff = mean(data(1:nHC, i, j))-...
                        mean(data(nHC+1:end, i, j));
                    dataSig = [dataSig data(:, i, j)];
                    if diff > 0
                        Psig = [Psig; strcat('Band', string(i)), ...
                            locations(j), "major in HC"];
                    else
                        Psig = [Psig; strcat('Band', string(i)), ...
                            locations(j), "major in PAT"];
                    end   
                end
            end
        end
    else
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        data = zeros(nHC+nPAT, nLoc);
        Psig = [string() string()];
        P = zeros(1, nLoc);
        alpha = alpha_levelling(cons, nLoc);
        
        for i = 1:nLoc
        	data(1:nHC, i) = sum(HC(:, i, :), 3)/(nLoc-1);
            data(nHC+1:end, i) = sum(PAT(:, i, :), 3)/(nLoc-1);
            P(1, i) = ranksum(data(1:nHC, i), data(nHC+1:end, i));
            
            if P(1, i) < alpha
                diff = mean(data(1:nHC, i))-mean(data(nHC+1:end, i));
                dataSig = [dataSig data(:, i)];
                if diff > 0
                    Psig = [Psig; locations(i), "major in HC"];
                else
                    Psig = [Psig; locations(i), "major in PAT"];
                end             
            end
        end
    end
    Psig(1, :) = [];
end