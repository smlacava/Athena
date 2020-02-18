%% impossible_analysis
% This function is used to check what analysis cannot be executed for any
% group of subjects, and what groups of subjects are not enabled for any 
% analysis
%
% [analysis, subjects] = impossible_analysis(dataPath, measure)
%
% input:
%   dataPath is the directory of the study
%   measure is the name of the analyzed measure (optional, it can be
%       included in the dataPath)
% 
% output:
%   analysis is the cell array which includes the list of the not
%       executable analysis (it is empty if each analysis can be executed
%       for almost a subjects' group)
%   subjects is the cell array which includes the list of the not
%       analyzable subjects' groups (it is empty if each subjects' group
%       can be analyzed in almost one analysis)


function [analysis, subjects] = impossible_analysis(dataPath, measure)
    if nargin == 1
        measure = '';
    else
        measure = path_check(char_check(measure));
    end
    dataPath = path_check(char_check(dataPath));
    dataPath = strcat(dataPath, measure, path_check('Epmean'));
    
    subjects = {'PAT.mat', 'HC.mat'};
    analysis = {'Total', 'Global', 'Asymmetry', 'Areas'};
    n_sub = length(subjects);
    n_an = length(analysis);
    sub_check = n_an*ones(1, n_sub);
    an_check = n_sub*ones(1, n_an);
    
    for i = 1:n_an
        for j = 1:n_sub
            data = load_data(strcat(dataPath, path_check(analysis{i}), ...
                subjects{j}));
            if isempty(data)
                an_check(i) = an_check(i)-1;
                sub_check(j) = sub_check(j)-1;
            end
        end
    end
    
    analysis(an_check > 0) = [];
    subjects(sub_check > 0) = [];
end
    
    