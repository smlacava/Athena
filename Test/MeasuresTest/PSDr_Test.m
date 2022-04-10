%This unit test the PSDr function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%These functions test the output of the PSDr function for different input
%parameters
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time
%band frequency bands

function tests = PSDr_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    try
        delete(append(dir, 'PSDr\*'));
        rmdir(append(dir, 'PSDr'));
    catch
    end

end


function teardownOnce(testCase)
    
    global dir

    try
        rmdir(append(dir, 'PSDr'));
    catch
    end
    
    clear
    close all
end


function teardown(testCase)

    global dir
    
    delete(append(dir, 'PSDr\*'));
    
end


function testBandPSDr(testCase)

    global fs cf n_ep dt t_start dir file_name

    resp = PSDr(fs, cf, n_ep, dt, dir, t_start, []);
    verifyEqual(testCase, resp, 0);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                                    %verify empty band, data should be empty

    resp = PSDr(fs, cf, n_ep, dt, dir, t_start, [0]);
    verifyEqual(testCase, resp, 0);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    PSDr(fs, cf, n_ep, dt, dir, t_start, [0 0]);
    exp = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEqual(testCase, psdr, exp);                               %verify zero band, data should be like a single value band

    resp = PSDr(fs, cf, 3, 20, dir, 70, [50]);
    verifyEqual(testCase, resp, 0);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    PSDr(fs, cf, n_ep, dt, dir, t_start, [50 50]);
    exp = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEqual(testCase, psdr, exp);                               %verify bad band, data should be like a single value band

end

function testTimeAndEpochsPSDr(testCase)

    global fs cf dir band  file_name
    
    resp = PSDr(fs, cf, 5, 20, dir, 0, band);
    verifyEqual(testCase, resp, 0);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                                                        %verify too many epochs, data should be empty
    
    resp = PSDr(fs, cf, 1, 70, dir, 0, band);
    verifyEqual(testCase, resp, 0);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                                                        %verify too long windows, should be empty

    resp = PSDr(fs, cf, 3, 20, dir, 70, band);
    verifyEqual(testCase, resp, 0);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                                                         %verify too long windows, should be a matrix of zeros
end


function testSamplingFrequencyPSDr(testCase)

    global cf n_ep dt t_start dir band file_name

    resp = PSDr(0, cf, n_ep, dt, dir, t_start, band);        
    verifyEqual(testCase, resp, -1);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                              %verify sampling frequency zero, data should be empty

end


function testCutFrequenciesPSDr(testCase)

    global fs n_ep dt t_start dir band series  file_name
    
    resp = PSDr(fs, [0], n_ep, dt, dir, t_start, band);
    verifyEqual(testCase, resp, -1);
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                              %verify cut frequencies null, data should be empty

    resp = PSDr(fs, [], n_ep, dt, dir, t_start, band);
    verifyEqual(testCase, resp, -1)
    psdr = loadFromDisk(append(dir, 'PSDr\', file_name));
    verifyEmpty(testCase, psdr);                              %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %        %how to test function on single sample
    %    end
    %end
end