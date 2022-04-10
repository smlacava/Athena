%This unit test the spectral_entropy function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%These functions test the output of the spectral_entropy function for different input
%parameters
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time

function tests = spectral_entropy_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    try
        delete(append(dir, 'PEntropy\*'));
        rmdir(append(dir, 'PEntropy'));
    catch
    end

end


function teardownOnce(testCase)
    
    global dir

    try
        rmdir(append(dir, 'PEntropy'));
    catch
    end
    
    clear
    close all

end


function teardown(testCase)

    global dir
    
    delete(append(dir, 'PEntropy\*'));
    
end


function testTimeAndEpochs_spectral_entropy(testCase)

    global fs cf dir file_name
    
    resp = spectral_entropy(fs, cf, 5, 20, dir, 0);
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);                                                          %verify too many epochs, data should be empty

    resp = spectral_entropy(fs, cf, 1, 70, dir, 0);
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);                                                          %verify too long windows, should be empty

    resp = spectral_entropy(fs, cf, 3, 20, dir, 70);
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);                                                          %verify too long windows, should be mepty

end


function testSamplingFrequency_spectral_entropy(testCase)

    global cf n_ep dt t_start dir file_name

    resp = spectral_entropy(0, cf, n_ep, dt, dir, t_start);         %verify sampling frequency zero, should be empty
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);

    resp = spectral_entropy([], cf, n_ep, dt, dir, t_start);        %verify sampling frequency null, should be empty
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);

end


function testCutFrequencies_spectral_entropy(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = spectral_entropy(fs, [0], n_ep, dt, dir, t_start);
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);                                      %verify cut frequencies zero, should be empty

    resp = spectral_entropy(fs, [], n_ep, dt, dir, t_start);
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'PEntropy\', file_name));
    verifyEmpty(testCase, se);                                      %verify cut frequencies empty, should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end