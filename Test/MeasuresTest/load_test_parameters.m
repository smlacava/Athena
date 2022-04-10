%This function load the parameters used for the test from a csv file
%Edit the csv file and this function to add parameters

function [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters(file)

    [cf,n_ep,dt,t_start,band,dir,file_name] = readvars(file);
    cf = cf';
    n_ep = n_ep(1);
    dt = dt(1);
    t_start = t_start(1);
    band = band';
    band = band(1:2);
    dir = dir{1, 1};
    file_name = file_name{1, 1};

end