%% conn_index
% This function is used to compute an index for some connectivity
% computations.
%
% idx = conn_index(data)
%
% input:
%   data is the data used in the computation
%
% output:
%   idx is the index


function idx = conn_index(data)
    idx = 3;
    if size(data, 2) == 1
        idx = 2;
    end
end