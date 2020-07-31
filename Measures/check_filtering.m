%% check_filtering
% This function checks if it is possible to compute the filtering step in
% extracting connectivity measures
%
% check = check_filtering(data, dt, tStart, fs, cf, filter_handle)
% 
% input:
%   data is the time series' matrix
%   dt is the length of the time window (in samples)
%   tStart is the starting time of the first time epoch
%   fs is the sampling frequency value
%   cf is the cut frequencies array
%   filter_handle is the handle of the filtering function
%
% output:
%   check is 0 if it is possible to compute the filtering step, while it is
%       1 if it is not possible


function check = check_filtering(data, dt, tStart, fs, cf, filter_handle)
    try
        ti = tStart;
        tf = dt+tStart-1;
        filter_handle(data(:, ti:tf), fs, cf(1), cf(2));
        check = 0;
    catch
        problem(strcat("There are not enough samples for the ", ...
            "filtering execution (use a greater time window length ", ...
            "or an higher minimum cut frequency)"))
        check = 1;
    end
end
    