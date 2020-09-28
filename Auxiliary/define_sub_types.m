%% define_sub_types
% This function defines the types of subjects through a file containing
% information about them
%
% [Subjects, sub_types, nSUB, nFirst, nSecond] = define_sub_types(subFile)
%
% Input:
%   subFile is the name of the file, with its path, containing the list of
%       the subjects
%
% Output:
%   Subjects is the matrix of the subjects
%   sub_types is the list of subjects' types
%   nSUB is the total number of subjects
%   nFirst is the number of subjects belonging to the first type
%   nSecond is the number of subjects belonging to the second type


function [Subjects, sub_types, nSUB, nFirst, nSecond] = ...
    define_sub_types(subFile)
    Subjects = load_data(subFile);
    try
        S = categorical(Subjects{:, end});
    catch
        S = categorical(Subjects(:, end));
    end
    sub_types = categories(S);
    nSUB = length(S);
    nFirst = sum(S == sub_types(1));
    nSecond = nSUB-nFirst;
end