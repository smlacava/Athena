%% mtt_glob
% This function computes the Wicox's analysis between global 
% not-connectivity measures of 2 different groups.
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

function [P, Psig, data, dataSig] = mtt_glob(PAT, HC, cons)
    dataSig = [];
    
    if length(size(HC)) == 3
        nBands = size(HC, 2);
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        data = zeros(nHC+nPAT, nBands);
        Psig = [string(), string()];
        P = zeros(nBands, 1);
        alpha = alpha_levelling(cons, nBands);
        
        for i = 1:nBands
        	data(1:nHC, i) = mean(HC(:, i, :), 3);
            data(nHC+1:end, i) = mean(PAT(:, i, :), 3);
            P(i, 1) = ranksum(data(1:nHC, i), data(nHC+1:end, i));
            if P(i, 1) < alpha
            	diff = mean(data(1:nHC, i))-mean(data(nHC+1:end, i));
                dataSig = [dataSig data(:, i)];
                if diff > 0
                	Psig = [Psig; strcat('Band', string(i)), ...
                        "major in HC'"];
                else
                    Psig = [Psig; strcat('Band', string(i)), ...
                        "major in PAT"];
                end
            end
        end
    else
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        data = zeros(nHC+nPAT, 1);
        Psig = string();
        
        data(1:nHC, 1) = mean(HC, 2);
        data(nHC+1:end, 1) = mean(PAT, 2);
        P = ranksum(data(1:nHC, 1), data(nHC+1:end, 1));
        alpha = alpha_levelling(cons);
            
        if P < alpha
        	diff = mean(data(1:nHC, 1))-mean(data(nHC+1:end, 1));
            dataSig = [dataSig data(:, 1)];  
            if diff > 0
            	Psig = [Psig; "major in HC"];
            else
                Psig = [Psig; "major in PAT"];
            end
        end
    end
    Psig(1, :) = [];
end