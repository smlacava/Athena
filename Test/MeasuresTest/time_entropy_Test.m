%This unit test the time_entropy function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%These functions test the output of the time_entropy function for different input
%parameters. Change outTypes for different entropy measures
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time
%outTyeps type of measure
%filter_name name of the filtering functio
%m embedding dimension
%r fraction of standard deviation

function tests = time_entropy_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    for x = {'discretized_entropy', 'sample_entropy', 'approximate_entropy'}
        
        try
            delete(append(dir, x{1}, '\*'));
            rmdir(append(dir, x{1}));
        catch
        end

    end
end


function teardownOnce(testCase)
    
    global dir

    try
        delete(append(dir, '1\*'));
        delete(append(dir, 'wrong\*'));
        rmdir(append(dir, '1'));
        rmdir(append(dir, 'wrong'));
    catch
    end

    clear
    close all

end


function teardown(testCase)

    global dir
    
    for x = {'discretized_entropy', 'sample_entropy', 'approximate_entropy'}
    
        delete(append(dir, x{1}, '\*'));
        
        try
            rmdir(append(dir, x{1}));
        catch
        end

    end
    
end


function testoutTypes_time_entropy(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = time_entropy(fs, cf, n_ep, dt, dir, t_start, 1);
    verifyEqual(testCase, resp, -1);
    te = loadFromDisk(append(dir, '1\', file_name));
    verifyEqual(testCase, te(: , end), zeros(length(te(:, end)), 1));          %verify bad out type, data should be a matrix of zeros

    resp = time_entropy(fs, cf, n_ep, dt, dir, t_start,'wrong');
    verifyEqual(testCase, resp, -1);
    te = loadFromDisk(append(dir, 'wrong\', file_name));
    verifyEqual(testCase, te(: , end), zeros(length(te(:, end)), 1));          %verify wrong out type, data should be a matrix of zeros

end


function testFilterName_time_entropy(testCase)

    global fs cf n_ep dt t_start dir file_name

    resp = time_entropy(fs, cf, n_ep, dt, dir, t_start,'discretized_entropy', 'wrong');
    verifyEqual(testCase, resp, -1);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);                                                                %verify wrong filter name, data should be empty

end


function testTimeAndEpochs_discretized_entropy(testCase)

    global fs cf dir file_name
    
    resp = time_entropy(fs, cf, 5, 20, dir, 0,'discretized_entropy');
    verifyEqual(testCase, resp, 0);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);                                                      %verify too many epochs, last column should be empty
    
    resp = time_entropy(fs, cf, 1, 70, dir, 0,'discretized_entropy');
    verifyEqual(testCase, resp, -1);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);                                                      %verify too long windows, data should be empty
    
    resp = time_entropy(fs, cf, 3, 20, dir, 70, 'discretized_entropy');
    verifyEqual(testCase, resp, -1);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);                                                      %verify too long windows, data should be empty

end


function testSamplingFrequency_discretized_entropy(testCase)

    global cf n_ep dt t_start dir file_name

    resp = time_entropy(0, cf, n_ep, dt, dir, t_start, 'discretized_entropy');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, 0);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);

    resp = time_entropy([], cf, n_ep, dt, dir, t_start, 'discretized_entropy');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, 0);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);

end


function testCutFrequencies_discretized_entropy(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = time_entropy(fs, [0], n_ep, dt, dir, t_start, 'discretized_entropy');
    verifyEqual(testCase, resp, -1);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);                                                      %verify cut frequencies zero, data should be empty
    
    resp = time_entropy(fs, [], n_ep, dt, dir, t_start, 'discretized_entropy');
    verifyEqual(testCase, resp, -1);
    de = loadFromDisk(append(dir, 'discretized_entropy\', file_name));
    verifyEmpty(testCase, de);                                                      %verify cut frequencies empty, data should be empty
   

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_sample_entropy(testCase)

    global fs cf dir file_name
    
    resp = time_entropy(fs, cf, 5, 20, dir, 0,'sample_entropy');
    verifyEqual(testCase, resp, 0);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEmpty(testCase, se);                                                          %verify too many epochs, last column should be empty

    resp = time_entropy(fs, cf, 1, 70, dir, 0,'sample_entropy');
    verifyEqual(testCase, resp, 0);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEqual(testCase, se(: , 1), zeros(length(se(:, 1)), 1));                        %verify too long windows, single column should be zero

    resp = time_entropy(fs, cf, 3, 20, dir, 70, 'sample_entropy');
    verifyEqual(testCase, resp, 0);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEqual(testCase, se, zeros(length(se(1, :)), length(se(:, 1))));                %verify too long windows, should be a matrix of zeros

end


function testSamplingFrequency_sample_entropy(testCase)

    global cf n_ep dt t_start dir file_name

    resp = time_entropy(0, cf, n_ep, dt, dir, t_start, 'sample_entropy');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, 0);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEmpty(testCase, se);

    resp = time_entropy([], cf, n_ep, dt, dir, t_start, 'sample_entropy');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, 0);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEmpty(testCase, se);

end


function testCutFrequencies_sample_entropy(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = time_entropy(fs, [0], n_ep, dt, dir, t_start, 'sample_entropy');
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEmpty(testCase, se);                                                 %verify cut frequencies zero, data should be empty

    resp = time_entropy(fs, [], n_ep, dt, dir, t_start, 'sample_entropy');
    verifyEqual(testCase, resp, -1);
    se = loadFromDisk(append(dir, 'sample_entropy\', file_name));
    verifyEmpty(testCase, se);                                                 %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_approximate_entropy(testCase)

    global fs cf dir file_name
    
    resp = time_entropy(fs, cf, 5, 20, dir, 0,'approximate_entropy');
    verifyEqual(testCase, resp, 0);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);                                                          %verify too many epochs, data should be empty

    resp = time_entropy(fs, cf, 1, 70, dir, 0,'approximate_entropy');
    verifyEqual(testCase, resp, -1);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);                                                          %verify too long windows, data should be empty

    resp = time_entropy(fs, cf, 3, 20, dir, 70, 'approximate_entropy');
    verifyEqual(testCase, resp, -1);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);                                                          %verify too long windows, data should be empty

end


function testSamplingFrequency_approximate_entropy(testCase)

    global cf n_ep dt t_start dir file_name

    resp = time_entropy(0, cf, n_ep, dt, dir, t_start, 'approximate_entropy');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, 0);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);

    resp = time_entropy([], cf, n_ep, dt, dir, t_start, 'approximate_entropy');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, 0);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);

end


function testCutFrequencies_approximate_entropy(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = time_entropy(fs, [0], n_ep, dt, dir, t_start, 'approximate_entropy');
    verifyEqual(testCase, resp, -1);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);                                                          %verify cut frequencies zero, data should be empty

    resp = time_entropy(fs, [], n_ep, dt, dir, t_start, 'approximate_entropy');
    verifyEqual(testCase, resp, -1);
    ae = loadFromDisk(append(dir, 'approximate_entropy\', file_name));
    verifyEmpty(testCase, ae);                                                           %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
        %for j = 1:size(series, 1)
        %    data = squeeze(series(j, dt*(k-1)+1:k*dt));
           
        %end
    %end
end