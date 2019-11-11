%% mtt_areas
% This function computes the Wicox's analysis between not-connectivity 
% measures of 2 different groups in Frontal, Temporal, Central, Parietal 
% and Occipital areas.
% 
% [P, Psig, data, dataSig, areas] = mtt_areas(PAT, HC, FrontalLoc, ...
%     TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc, cons)
%
% input:
%   PAT is the name of the file (with its directory) which contains the
%   	matrix subjects*bands*locations of the patients group
%   HC is the name of the file (with its directory) which contains the
%       matrix subjects*bands*locations of the healthy controls group
%   FrontalLoc is the array of indexes of the frontal locations
%   TemporalLoc is the array of the indexes of the temporal locations
%   OccipitalLoc is the array of the indexes of the occipital locations
%   ParietalLoc is the array of the indexes of the parietal locations
%   CentralLoc is the array of the indexes of the central locations
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
%   areas is the array which contains the names of the compared areas


function [P, Psig, data, dataSig, areas] = mtt_areas(PAT, HC, ...
    FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc, cons)
    Front = length(FrontalLoc);
    Temp = length(TemporalLoc);
    Occ = length(OccipitalLoc);
    Par = length(ParietalLoc);
    Cent = length(CentralLoc);
    areas = string();
    nLoc = 0;
    dataSig = [];
    if Front ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Frontal"];
    end
    if Temp ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Temporal"];
    end
    if Occ ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Occipital"];
    end
    if Par ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Parietal"];
    end
    if Cent ~= 0
        nLoc = nLoc+1;
        areas = [areas, "Central"];
    end
    areas(1) = [];
    
    if length(size(HC)) == 3
        nBands = size(HC, 2);
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        HC_areas = zeros(nHC, nBands, nLoc);
        PAT_areas = zeros(nPAT, nBands, nLoc);
        
        loc = 1;
        if Front ~= 0
            HC_areas(:, :, loc) = mean(HC(:, :, FrontalLoc), 3);
            PAT_areas(:, :, loc) = mean(PAT(:, :, FrontalLoc), 3);
            loc = loc+1;
        end
        if Temp ~= 0
            HC_areas(:, :, loc) = mean(HC(:, :, TemporalLoc), 3);
            PAT_areas(:, :, loc) = mean(PAT(:, :, TemporalLoc), 3);
            loc = loc+1;
        end
        if Occ ~= 0
            HC_areas(:, :, loc) = mean(HC(:, :, OccipitalLoc), 3);
            PAT_areas(:, :, loc) = mean(PAT(:, :, OccipitalLoc), 3);
            loc = loc+1;
        end
        if Par ~= 0
            HC_areas(:, :, loc) = mean(HC(:, :, ParietalLoc), 3);
            PAT_areas(:, :, loc) = mean(PAT(:, :, ParietalLoc), 3);
            loc = loc+1;
        end
        if Cent ~= 0
            HC_areas(:, :, loc) = mean(HC(:, :, CentralLoc), 3);
            PAT_areas(:, :, loc) = mean(PAT(:, :, CentralLoc), 3);
        end
        
        data = zeros(nHC+nPAT, nBands, nLoc);
        Psig = [string(), string(), string()];
        P = zeros(nBands, nLoc);
        alpha = alpha_levelling(cons, nLoc, nBands);
        
        for i = 1:nBands
            for j = 1:nLoc
                data(1:nHC, i, j) = HC_areas(:, i, j);
                data(nHC+1:end, i, j) = PAT_areas(:, i, j);
                P(i, j) = ranksum(data(1:nHC, i, j), ...
                    data(nHC+1:end, i, j));
                if P(i, j) < alpha
                    diff = mean(data(1:nHC, i, j))-...
                        mean(data(nHC+1:end, i, j));
                    dataSig = [dataSig data(:, i, j)];
                    if diff > 0
                        Psig = [Psig; strcat("Band ", string(i)), ...
                            areas(j), "major in HC"];
                    else
                        Psig = [Psig; strcat("Band ", string(i)), ...
                            areas(j), "major in PAT"];
                    end
                end
            end
        end
    else
        nPAT = size(PAT, 1);
        nHC = size(HC, 1);
        
        HC_areas = zeros(nHC, nLoc);
        PAT_areas = zeros(nPAT, nLoc);
        
        loc = 1;
        if Front ~= 0
            HC_areas(:, loc) = mean(HC(:, FrontalLoc), 2);
            PAT_areas(:, loc) = mean(PAT(:, FrontalLoc), 2);
            loc = loc+1;
        end
        if Temp ~= 0
            HC_areas(:, loc) = mean(HC(:, TemporalLoc), 2);
            PAT_areas(:, loc) = mean(PAT(:, TemporalLoc), 2);
            loc = loc+1;
        end
        if Occ ~= 0
            HC_areas(:, loc) = mean(HC(:, OccipitalLoc), 2);
            PAT_areas(:, loc) = mean(PAT(:, OccipitalLoc), 2);
            loc = loc+1;
        end
        if Par ~= 0
            HC_areas(:, loc) = mean(HC(:, ParietalLoc), 2);
            PAT_areas(:, loc) = mean(PAT(:, ParietalLoc), 2);
            loc = loc+1;
        end
        if Cent ~= 0
            HC_areas(:, loc) = mean(HC(:, CentralLoc), 2);
            PAT_areas(:, loc) = mean(PAT(:, CentralLoc), 2);
        end
        
        data = zeros(nHC+nPAT, nLoc);
        Psig = string();
        P = zeros(1, nLoc);
        alpha = alpha_levelling(cons, nLoc);
        
        for i = 1:nLoc
        	data(1:nHC, i) = HC_areas(:, i);
            data(nHC+1:end, i) = PAT_areas(:, i);
            P(1, i) = ranksum(data(1:nHC, i), data(nHC+1:end, i));
            
            if P(1, i) < alpha
                diff = mean(data(1:nHC, i))-mean(data(nHC+1:end, i));
                dataSig = [dataSig data(:, i)];
                if diff > 0
                    Psig = [Psig; areas(i), "major in HC"];
                else
                    Psig = [Psig; areas(i), "major in PAT"];
                end
            end
        end
    end
    Psig(1, :) = [];
end