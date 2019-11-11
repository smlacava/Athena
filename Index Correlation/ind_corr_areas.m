%% ind_corr_areas
% This function is used to compute the correlation with an index in
% Frontal, Temporal, Central, Parietal and Occipital areas of
% not-connectivity measure.
%
% [RHO, P, RHOsig, areas] = ind_corr_areas(data, Ind, FrontalLoc, ...
%     TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc, cons, ...
%     measure, sub)
%
% input:
%   data is a matrix which contains the values of the measure to correlate
%       for each subject
%   Ind is the index to correlate of each subject
%   FrontalLoc is an array which contains all the indexes of the frontal 
%       locations
%   TemporalLoc is an array which contains all the indexes of the temporal 
%       locations
%   OccipitalLoc is an array which contains all the indexes of the
%       occipital locations
%   ParietalLoc is an array which contains all the indexes of the parietal 
%       locations
%   CentralLoc is an array which contains all the indexes of the central 
%       locations
%   cons is the conservativeness level (0 = minumum, 1 = maximum)
%   measure is the name of the measure to correlate
%   sub is an array which contains the name of each subject
%
% output:
%   RHO is the matric which contains Spearman's correlation index of each 
%       area
%   P is the matrix which contains the p-value of each area
%   RHOsig is the matrix which contains information about the significant 
%       correlations
%   areas is an array which contains the names of the areas (if there is
%       not any location for an area, its name will not be present in this
%       array)

function [RHO, P, RHOsig, areas] = ind_corr_areas(data, Ind, ...
    FrontalLoc, TemporalLoc, OccipitalLoc, ParietalLoc, CentralLoc, ...
    cons, measure, sub)
    Front = length(FrontalLoc);
    Temp = length(TemporalLoc);
    Occ = length(OccipitalLoc);
    Par = length(ParietalLoc);
    Cent = length(CentralLoc);
    areas = string();
    nLoc = 0;
    Ind = Ind(:, end);
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
    
    if length(size(data)) == 3
        nBands = size(data, 2);
        RHOsig=[string() string() string()];
        data_areas = zeros(size(data, 1), nBands, nLoc);
        
        loc = 1;
        if Front ~= 0
            data_areas(:, :, loc) = mean(data(:, :, FrontalLoc), 3);
            loc = loc+1;
        end
        if Temp ~= 0
            data_areas(:, :, loc) = mean(data(:, :, TemporalLoc), 3);
            loc = loc+1;
        end
        if Occ ~= 0
            data_areas(:, :, loc) = mean(data(:, :, OccipitalLoc), 3);
            loc = loc+1;
        end
        if Par ~= 0
            data_areas(:, :, loc) = mean(data(:, :, ParietalLoc), 3);
            loc = loc+1;
        end
        if Cent ~= 0
            data_areas(:, :, loc) = mean(data(:, :, CentralLoc), 3);
        end
        
        P = zeros(nBands, nLoc);
        RHO = P;
        alpha = alpha_levelling(cons, nLoc, nBands);
        
        for i = 1:nBands
            for j = 1:nLoc
                [RHO(i, j), P(i, j)] = corr(Ind, data_areas(:, i, j), ...
                    'type', 'Spearman');
                if P(i, j) < alpha
                    RHOsig = [RHOsig; strcat('Band ', string(i)), ...
                        areas(j), string(RHO(i, j))];
                    correlation(Ind, data_areas(:, i, j), ...
                        strcat(areas(j), ', Band ', string(i)), ...
                        'Index', measure, sub);
                end
            end
        end

    else  
        data_areas = zeros(size(data, 1), nLoc);
        loc = 1;
        if Front ~= 0
            data_areas(:, loc) = mean(data(:, FrontalLoc), 2);
            loc = loc+1;
        end
        if Temp ~= 0
            data_areas(:, loc) = mean(data(:, TemporalLoc), 2);
            loc = loc+1;
        end
        if Occ ~= 0
            data_areas(:, loc) = mean(data(:, OccipitalLoc), 2);
            loc = loc+1;
        end
        if Par ~= 0
            data_areas(:, loc) = mean(data(:, ParietalLoc), 2);
            loc = loc+1;
        end
        if Cent ~= 0
            data_areas(:, loc) = mean(data(:, CentralLoc), 2);
        end
        
        P = zeros(1, nLoc);
        RHO = P;
        RHOsig = [string() string()];
        alpha = alpha_levelling(cons, nLoc);
        
        for i = 1:nLoc
        	[RHO(1, i), P(1, i)] = corr(Ind, data_areas(:, i), 'type', ...
                'Spearman');
            
            if P(1, i) < alpha
            	RHOsig = [RHOsig; areas(i), string(RHO(1, i))];
                correlation(Ind, data(:, i), areas(i), 'Index', ...
                    measure, sub);
            end
        end
    end
    RHOsig(1, :)=[];
end