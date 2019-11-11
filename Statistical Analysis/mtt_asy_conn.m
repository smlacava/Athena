%% mtt_asy_conn
% This function computes the Wicox's analysis between the asymmetry in 
% connectivity measures of 2 different groups.
% 
% [P, Psig, data, dataSig] = mtt_asy_conn(PAT, HC, RightLoc, LeftLoc, cons)
%
% input:
%   PAT is the name of the file (with its directory) which contains the
%   	matrix subjects*bands*locations of the patients group
%   HC is the name of the file (with its directory) which contains the
%       matrix subjects*bands*locations of the healthy controls group
%   RightLoc is the array of the right locations
%   LeftLoc is the array of the left locations
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

function [P, Psig, data, dataSig] = mtt_asy_conn(PAT, HC, RightLoc, ...
    LeftLoc, cons)
    R = length(RightLoc);
    R = R*R-R;
    L = length(LeftLoc);
    L = L*L-L;
    dataSig = [];
    
    if length(size(HC)) == 4
        nBands = size(HC, 2);
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        HC_asy = zeros(nHC, nBands, 2);
        HC_asy(:, :, 1) = sum(squeeze(sum(...
            HC(:, :, RightLoc, RightLoc), 3)), 3)/R;
        HC_asy(:, :, 2) = sum(squeeze(sum(...
            HC(:, :, LeftLoc, LeftLoc), 3)), 3)/L;
        
        PAT_asy = zeros(nPAT, nBands, 2);
        PAT_asy(:, :, 1) = sum(squeeze(sum(...
            PAT(:, :, RightLoc, RightLoc), 3)), 3)/R;
        PAT_asy(:, :, 2) = sum(squeeze(sum(...
            PAT(:, :, LeftLoc, LeftLoc), 3)), 3)/L;
        
        data = zeros(nHC+nPAT, nBands);
        Psig = [string(), string()];
        P = zeros(nBands, 1);
        alpha = alpha_levelling(cons, nBands);
            
        for i = 1:nBands
            data(1:nHC, i) = abs(HC_asy(:, i, 1)-HC_asy(:, i, 2));
            data(nHC+1:end, i) = abs(PAT_asy(:, i, 1)-PAT_asy(:, i, 2));
            P(i, 1) = ranksum(data(1:nHC, i), data(nHC+1:end, i));
            
            if P(i, 1) < alpha
                diff = mean(data(1:nHC, i))-mean(data(nHC+1:end, i));
                
                if diff > 0
                    Psig = [Psig; strcat('Band ', string(i)), "HC"];
                else
                    Psig=[Psig; strcat('Band ',string(i)), "PAT"];
                end
                
            end
        end
        Psig(1, :) = [];
        
    else
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
    
        HC_asy = zeros(nHC, 2);
        HC_asy(:, 1) = sum(squeeze(sum(...
            HC(:, RightLoc, RightLoc), 2)), 2)/R;
        HC_asy(:, 2) = sum(squeeze(sum(...
            HC(:, LeftLoc, LeftLoc), 2)), 2)/L;
    
        PAT_asy = zeros(nPAT, 2);
        PAT_asy(:, 1) = sum(squeeze(sum(...
            PAT(:, RightLoc, RightLoc), 2)), 2)/R;
        PAT_asy(:, 2) = sum(squeeze(sum(...
            PAT(:, LeftLoc, LeftLoc), 2)), 2)/L;
        
        data = zeros(nHC+nPAT, 1);
        data(1:nHC, 1) = abs(HC_asy(:, 1)-HC_asy(:, 2));
        data(nHC+1:end, 1) = abs(PAT_asy(:, 1)-PAT_asy(:, 2));
        
        P = ranksum(data(1:nHC, 1), data(nHC+1:end, 1));
        Psig = "";
        alpha = alpha_levelling(cons);
        
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