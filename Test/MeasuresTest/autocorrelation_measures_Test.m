%This unit test the autocorrelation_measures function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%This functions test the output of the autocorrelation_measures function for different input
% parameters. Change outTypes for different entropy measures
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time
%outTyeps type of measure
%filter_name name of the filtering functio


function tests = autocorrelation_measures_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    try
        delete(append(dir, 'Hurst\*'));
        rmdir(append(dir, 'Hurst'));
    catch
    end

end


function teardownOnce(testCase)

    global dir
    
    clear
    close all

    try
        rmdir(append(dir, 'Hurst'));
    catch
    end

    try
        delete(append(dir, '1\*'));
        delete(append(dir, 'wrong\*'));
        rmdir(append(dir, '1'));
        rmdir(append(dir, 'wrong'));
    catch
    end

end


function teardown(testCase)

    global dir
    
    delete(append(dir, 'Hurst\*'));
    
end


function testoutTypes_autocorrelation_measures(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = autocorrelation_measures(fs, cf, n_ep, dt, dir, t_start, 1);
    verifyEqual(testCase, resp, -1);
    am = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, am);                                                          %verify bad out type, data should be empty

    resp = autocorrelation_measures(fs, cf, n_ep, dt, dir, t_start,'wrong');
    verifyEqual(testCase, resp, -1);
    am = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, am);                                                          %verify wrong out type, data should be empty

end


function testFilterName_autocorrelation_measures(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = autocorrelation_measures(fs, cf, n_ep, dt, dir, t_start, 'Hurst', 'wrong');
    verifyEqual(testCase, resp, -1);
    am = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, am);                                                                %verify wrong filter name, data should be empty

end


function testTimeAndEpochs_hurst_index(testCase)

    global fs cf dir file_name
    
    resp = autocorrelation_measures(fs, cf, 5, 20, dir, 0,'Hurst');
    verifyEqual(testCase, resp, 0);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, he);                                                          %verify too many epochs, data should be empty

    resp = autocorrelation_measures(fs, cf, 1, 70, dir, 0,'Hurst');
    verifyEqual(testCase, resp, -1);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifympty(testCase, he);                                                           %verify too long windows, should be empty
    
    resp = autocorrelation_measures(fs, cf, 3, 20, dir, 70, 'Hurst');
    verifyEqual(testCase, resp, 0);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, he);                                                          %verify too long windows, should be empty   

end


function testSamplingFrequency_hurst_index(testCase)

    global cf n_ep dt t_start dir

    resp = autocorrelation_measures(0, cf, n_ep, dt, dir, t_start, 'Hurst');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, 0);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, he);
    
    resp = autocorrelation_measures([], cf, n_ep, dt, dir, t_start, 'Hurst');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, 0);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, he);

end


function testCutFrequencies_hurst_index(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = autocorrelation_measures(fs, [0], n_ep, dt, dir, t_start, 'Hurst');
    verifyEqual(testCase, resp, -1);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, he);                                                        %verify cut frequencies zero, data should be empty

    resp = autocorrelation_measures(fs, [], n_ep, dt, dir, t_start, 'Hurst');
    verifyEqual(testCase, resp, 0);
    he = loadFromDisk(append(dir, 'Hurst\', file_name));
    verifyEmpty(testCase, he);                                                        %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end