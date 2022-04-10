%This unit test the statistical_information function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%This functions test the output of the statistical_information function for different input
%parameters. Change outTypes for different entropy measures
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time
%outTyeps type of measure 
%filter_name name of the filter

function tests = statistical_information_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    for x = {'Median', 'Mean', 'Standard_deviation', 'Variance', 'Skewness', 'Kurtosis'}
        
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
    
    for x = {'Median', 'Mean', 'Standard_deviation', 'Variance', 'Skewness', 'Kurtosis'}
    
        delete(append(dir, x{1}, '\*'));

        try
            rmdir(append(dir,  x{1}));
        catch
        end

    end
    
end


function testoutTypes_statistical_information(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = statistical_information(fs, cf, n_ep, dt, dir, t_start, 1);
    verifyEqual(testCase, resp, -1);
    sa = loadFromDisk(append(dir, '1\', file_name));
    verifyEqual(testCase, sa, zeros(length(sa(:, 1)), length(sa(1, :))));           %verify bad out type, data should be a matrix of zeros

    resp = statistical_information(fs, cf, n_ep, dt, dir, t_start,'wrong'); 
    verifyEqual(testCase, resp, -1);
    sa = loadFromDisk(append(dir, 'wrong\', file_name));
    verifyEqual(testCase, sa, zeros(length(sa(:, 1)), length(sa(1, :))));           %verify wrong out type, data should be a matrix of zeros

end


function testFilterName_statistical_information(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = statistical_information(fs, cf, n_ep, dt, dir, t_start,'Median', 'wrong');
    verifyEqual(testCase, resp, -1);
    sa = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, sa);                                                                    %verify wrong filter name, data should be empty

end


function testTimeAndEpochs_median(testCase)

    global fs cf dir file_name
    
    resp = statistical_information(fs, cf, 5, 20, dir, 0,'Median');
    verifyEqual(testCase, resp, 0);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);                                                     %verify too many epochs, data should be empty

    resp = statistical_information(fs, cf, 1, 70, dir, 0,'Median');
    verifyEqual(testCase, resp, -1);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);                                                     %verify too long windows, data should be empty

    resp = statistical_information(fs, cf, 3, 20, dir, 70, 'Median');
    verifyEqual(testCase, resp, -1);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);                                                     %verify too long windows, data should be empty

end


function testSamplingFrequency_median(testCase)

    global cf n_ep dt t_start dir file_name

    resp = statistical_information(0, cf, n_ep, dt, dir, t_start, 'Median');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);

    resp = statistical_information([], cf, n_ep, dt, dir, t_start, 'Median');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);

end


function testCutFrequencies_median(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = statistical_information(fs, [0], n_ep, dt, dir, t_start, 'Median');
    verifyEqual(testCase, resp, -1);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);                                                      %verify cut frequencies zero, data should be empty
    
    resp = statistical_information(fs, [], n_ep, dt, dir, t_start, 'Median');
    verifyEqual(testCase, resp, -1);
    md = loadFromDisk(append(dir, 'Median\', file_name));
    verifyEmpty(testCase, md);                                                      %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_mean(testCase)

    global fs cf dir file_name
    
    resp = statistical_information(fs, cf, 5, 20, dir, 0,'Mean');
    verifyEqual(testCase, resp, 0);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);                                                       %verify too many epochs, data should be empty

    resp = statistical_information(fs, cf, 1, 70, dir, 0,'Mean');
    verifyEqual(testCase, resp, -1);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);                                                       %verify too long windows, data should be empty

    resp = statistical_information(fs, cf, 3, 20, dir, 70, 'Mean');
    verifyEqual(testCase, resp, -1);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);                                                        %verify too long windows, data should be empty

end


function testSamplingFrequency_mean(testCase)

    global cf n_ep dt t_start dir file_name

    resp = statistical_information(0, cf, n_ep, dt, dir, t_start, 'Mean');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);

    resp = statistical_information([], cf, n_ep, dt, dir, t_start, 'Mean');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);

end


function testCutFrequencies_mean(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = statistical_information(fs, [0], n_ep, dt, dir, t_start, 'Mean');
    verifyEqual(testCase, resp, -1);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);                                                       %verify cut frequencies zero, data should be empty

    resp = statistical_information(fs, [], n_ep, dt, dir, t_start, 'Mean');
    verifyEqual(testCase, resp, -1);
    m = loadFromDisk(append(dir, 'Mean\', file_name));
    verifyEmpty(testCase, m);                                                       %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_standard_deviation(testCase)

    global fs cf dir file_name
    
    resp = statistical_information(fs, cf, 5, 20, dir, 0,'Standard_deviation');
    verifyEqual(testCase, resp, 0);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);                                                            %verify too many epochs, data should be empty

    resp = statistical_information(fs, cf, 1, 70, dir, 0,'Standard_deviation');
    verifyEqual(testCase, resp, -1);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);                                                             %verify too long windows, data should be empty

    resp = statistical_information(fs, cf, 3, 20, dir, 70, 'Standard_deviation');
    verifyEqual(testCase, resp, -1);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);                                                             %verify too long windows, data should be empty

end


function testSamplingFrequency_standard_deviation(testCase)

    global cf n_ep dt t_start dir

    resp = statistical_information(0, cf, n_ep, dt, dir, t_start, 'Standard_deviation');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);

    resp = statistical_information([], cf, n_ep, dt, dir, t_start, 'Standard_deviation');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);

end


function testCutFrequencies_standard_deviation(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = statistical_information(fs, [0], n_ep, dt, dir, t_start, 'Standard_deviation');
    verifyEqual(testCase, resp, -1);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);                                                                %verify cut frequencies zero, data should be empty

    resp = statistical_information(fs, [], n_ep, dt, dir, t_start, 'Standard_deviation');
    verifyEqual(testCase, resp, -1);
    std = loadFromDisk(append(dir, 'Standard_deviation\', file_name));
    verifyEmpty(testCase, std);                                                                %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_variance(testCase)

    global fs cf dir file_name
    
    resp = statistical_information(fs, cf, 5, 20, dir, 0,'Variance');
    verifyEqual(testCase, resp, 0);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);                                                          %verify too many epochs, data should be empty

    resp = statistical_information(fs, cf, 1, 70, dir, 0,'Variance');
    verifyEqual(testCase, resp, -1);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);                                                           %verify too long windows, data should be empty

    resp = statistical_information(fs, cf, 3, 20, dir, 70, 'Variance');
    verifyEqual(testCase, resp, -1);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);                                                           %verify too long windows, data should be empty
end


function testSamplingFrequency_variance(testCase)

    global cf n_ep dt t_start dir file_name

    resp = statistical_information(0, cf, n_ep, dt, dir, t_start, 'Variance');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);

    resp = statistical_information([], cf, n_ep, dt, dir, t_start, 'Variance');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);

end


function testCutFrequencies_variance(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = statistical_information(fs, [0], n_ep, dt, dir, t_start, 'Variance');
    verifyEqual(testCase, resp, -1);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);                                                          %verify cut frequencies zero, data should be empty

    resp = statistical_information(fs, [], n_ep, dt, dir, t_start, 'Variance');
    verifyEqual(testCase, resp, -1);
    v = loadFromDisk(append(dir, 'Variance\', file_name));
    verifyEmpty(testCase, v);                                                          %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end
end


function testTimeAndEpochs_skewness(testCase)

    global fs cf dir file_name
    
    resp = statistical_information(fs, cf, 5, 20, dir, 0,'Skewness');
    verifyEqual(testCase, resp, 0);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);                                                          %verify too many epochs, data should be empty

    resp = statistical_information(fs, cf, 1, 70, dir, 0,'Skewness');
    verifyEqual(testCase, resp, -1);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);                                                          %verify too long windows, data should be empty

    resp = statistical_information(fs, cf, 3, 20, dir, 70, 'Skewness');
    verifyEqual(testCase, resp, -1);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);                                                          %verify too long windows, data should be empty

end


function testSamplingFrequency_skewness(testCase)

    global cf n_ep dt t_start dir file_name

    resp = statistical_information(0, cf, n_ep, dt, dir, t_start, 'Skewness');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);

    resp = statistical_information([], cf, n_ep, dt, dir, t_start, 'Skewness');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);

end


function testCutFrequencies_skewness(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = statistical_information(fs, [0], n_ep, dt, dir, t_start, 'Skewness');
    verifyEqual(testCase, resp, -1);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);                                                     %verify cut frequencies zero, data should be empty

    resp = statistical_information(fs, [], n_ep, dt, dir, t_start, 'Skewness');
    verifyEqual(testCase, resp, -1);
    sk = loadFromDisk(append(dir, 'Skewness\', file_name));
    verifyEmpty(testCase, sk);                                                     %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end
end


function testTimeAndEpochs_kurtosis(testCase)

    global fs cf dir file_name
    
    resp = statistical_information(fs, cf, 5, 20, dir, 0,'Kurtosis');
    verifyEqual(testCase, resp, 0);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);                                                          %verify too many epochs, data should be empty

    resp = statistical_information(fs, cf, 1, 70, dir, 0,'Kurtosis');        
    verifyEqual(testCase, resp, -1);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);                                                          %verify too long windows, data should be empty

    resp = statistical_information(fs, cf, 3, 20, dir, 70, 'Kurtosis');
    verifyEqual(testCase, resp, -1);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);                                                          %verify too long windows, data should be empty

end


function testSamplingFrequency_kurtosis(testCase)

    global cf n_ep dt t_start dir file_name

    resp = statistical_information(0, cf, n_ep, dt, dir, t_start, 'Kurtosis');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);

    resp = statistical_information([], cf, n_ep, dt, dir, t_start, 'Kurtosis');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);

end


function testCutFrequencies_kurtosis(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = statistical_information(fs, [0], n_ep, dt, dir, t_start, 'Kurtosis');
    verifyEqual(testCase, resp, -1);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);                                                     %verify cut frequencies zero, data should be empty

    resp = statistical_information(fs, [], n_ep, dt, dir, t_start, 'Kurtosis');
    verifyEqual(testCase, resp, -1);
    ku = loadFromDisk(append(dir, 'Kurtosis\', file_name));
    verifyEmpty(testCase, ku);                                                     %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end
end