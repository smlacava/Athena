%This unit test the connectivity function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%This functions test the output of the connectivity function for different input
%parameters. Change outTypes for different entropy measures
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time
%outTyeps type of measure 
%filter_name name of the filter

function tests = connectivity_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    for x = {'PLI', 'PLV', 'AEC', 'AECo', 'Coherence', 'ICOH', 'correlation_coefficient', 'wPLI', 'mutual_information'}
        
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
    
    for x = {'PLI', 'PLV', 'AEC', 'AECo', 'Coherence', 'ICOH', 'correlation_coefficient', 'wPLI', 'mutual_information'}
    
        delete(append(dir, x{1}, '\*'));

        try
            rmdir(append(dir,  x{1}));
        catch
        end

    end
    
end


function testoutTypes_connectivity(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = connectivity(fs, cf, n_ep, dt, dir, t_start, 1);
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, '1\', file_name));
    verifyEqual(testCase, co, zeros(length(co(:, 1)), length(co(1, :))));            %verify bad out type, data should be zero

    resp = connectivity(fs, cf, n_ep, dt, dir, t_start,'wrong');
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'wrong\', file_name));
    verifyEqual(testCase, co, zeros(length(co(:, 1)), length(co(1, :))));            %verify wrong out type, data should be zero

end

function testFilterName_connectivity(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = connectivity(fs, cf, n_ep, dt, dir, t_start,'PLI', 'wrong');
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, co);                                                                %verify wrong filter name, data should be empty

end

function testTimeAndEpochs_PLI(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'PLI');
    verifyEqual(testCase, resp, 0);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);                                                            %verify too many epochs, should be empty

    resp = connectivity(fs, cf, 1, 70, dir, 0,'PLI');
    verifyEqual(testCase, resp, -1);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);                                                            %verify too long windows, should be empty

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'PLI');
    verifyEqual(testCase, resp, -1);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);                                                            %verify too long windows, should be empty

end


function testSamplingFrequency_PLI(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'PLI');             %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'PLI');            %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);

end


function testCutFrequencies_PLI(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'PLI');
    verifyEqual(testCase, resp, -1);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);                                            %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'PLI');
    verifyEqual(testCase, resp, -1);
    pli = loadFromDisk(append(dir, 'PLI\', file_name));
    verifyEmpty(testCase, pli);                                            %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_PLV(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'PLV');
    verifyEqual(testCase, resp, 0);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);                                                            %verify too many epochs, should be empty

    resp = connectivity(fs, cf, 1, 70, dir, 0,'PLV');
    verifyEqual(testCase, resp, -1);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);                                                            %verify too long windows, should be empty

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'PLV');
    verifyEqual(testCase, resp, -1);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);                                                            %verify too long windows, should be empty

end


function testSamplingFrequency_PLV(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'PLV');             %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'PLV');            %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);

end


function testCutFrequencies_PLV(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'PLV');
    verifyEqual(testCase, resp, -1);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);                                            %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'PLV');
    verifyEqual(testCase, resp, -1);
    plv = loadFromDisk(append(dir, 'PLV\', file_name));
    verifyEmpty(testCase, plv);                                            %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_AEC(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'AEC');
    verifyEqual(testCase, resp, 0);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);                                            %verify too many epochs, should be empty

    resp = connectivity(fs, cf, 1, 70, dir, 0,'AEC');
    verifyEqual(testCase, resp, -1);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);                                            %verify too long windows, should be empty

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'AEC');
    verifyEqual(testCase, resp, -1);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);                                            %verify too long windows, should be empty

end


function testSamplingFrequency_AEC(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'AEC');             %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'AEC');            %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);

end


function testCutFrequencies_AEC(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'AEC');
    verifyEqual(testCase, resp, -1);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);                                            %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'AEC');
    verifyEqual(testCase, resp, -1);
    aec = loadFromDisk(append(dir, 'AEC\', file_name));
    verifyEmpty(testCase, aec);                                            %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_AECo(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'AECo');
    verifyEqual(testCase, resp, 0);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);                                           %verify too many epochs, should be empty

    resp = connectivity(fs, cf, 1, 70, dir, 0,'AECo');
    verifyEqual(testCase, resp, -1);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);                                           %verify too long windows, should be empty

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'AECo');
    verifyEqual(testCase, resp, -1);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);                                           %verify too long windows, should be empty

end


function testSamplingFrequency_AECo(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'AECo');            %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'AECo');           %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);

end


function testCutFrequencies_AECo(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'AECo');
    verifyEqual(testCase, resp, -1);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);                                           %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'AECo');
    verifyEqual(testCase, resp, -1);
    aeco = loadFromDisk(append(dir, 'AECo\', file_name));
    verifyEmpty(testCase, aeco);                                           %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_coherence(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'Coherence');
    verifyEqual(testCase, resp, 0);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);                                                          %verify too many epochs, should be empty

    resp = connectivity(fs, cf, 1, 70, dir, 0,'Coherence');
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);                                                          %verify too long windows, should be empty

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'Coherence');
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);                                                          %verify too long windows, should be empty

end


function testSamplingFrequency_coherence(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'Coherence');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'Coherence');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);

end


function testCutFrequencies_coherence(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'Coherence');
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);                                             %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'Coherence');
    verifyEqual(testCase, resp, -1);
    co = loadFromDisk(append(dir, 'Coherence\', file_name));
    verifyEmpty(testCase, co);                                             %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_ICOH(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'ICOH');
    verifyEqual(testCase, resp, 0);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);                                            %verify too many epochs, last column should be zero

    resp = connectivity(fs, cf, 1, 70, dir, 0,'ICOH');
    verifyEqual(testCase, resp, -1);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);                                            %verify too long windows, single column should be zero

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'ICOH');
    verifyEqual(testCase, resp, -1);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);                                            %verify too long windows, should be a matrix of zeros

end


function testSamplingFrequency_ICOH(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'ICOH');            %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'ICOH');           %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);

end


function testCutFrequencies_ICOH(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'ICOH');
    verifyEqual(testCase, resp, -1);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);                                            %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'ICOH');
    verifyEqual(testCase, resp, -1);
    ico = loadFromDisk(append(dir, 'ICOH\', file_name));
    verifyEmpty(testCase, ico);                                            %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_correlation_coefficient(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'correlation_coefficient');
    verifyEqual(testCase, resp, 0);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);                                             %verify too many epochs, last column should be zero

    resp = connectivity(fs, cf, 1, 70, dir, 0,'correlation_coefficient');
    verifyEqual(testCase, resp, -1);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);                                             %verify too long windows, single column should be zero

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'correlation_coefficient');
    verifyEqual(testCase, resp, -1);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);                                             %verify too long windows, should be a matrix of zeros

end


function testSamplingFrequency_correlation_coefficient(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'correlation_coefficient');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'correlation_coefficient');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);

end


function testCutFrequencies_correlation_coefficient(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'correlation_coefficient');
    verifyEqual(testCase, resp, -1);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);                                                               %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'correlation_coefficient');
    verifyEqual(testCase, resp, -1);
    cc = loadFromDisk(append(dir, 'correlation_coefficient\', file_name));
    verifyEmpty(testCase, cc);                                                               %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_wPLI(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'wPLI');
    verifyEqual(testCase, resp, 0);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);                                              %verify too many epochs, last column should be zero

    resp = connectivity(fs, cf, 1, 70, dir, 0,'wPLI');
    verifyEqual(testCase, resp, -1);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);                                              %verify too long windows, single column should be zero

    resp = connectivity(fs, cf, 3, 20, dir, 70, 'wPLI');
    verifyEqual(testCase, resp, -1);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);                                              %verify too long windows, should be a matrix of zeros

end


function testSamplingFrequency_wPLI(testCase)

    global cf n_ep dt t_start dir file_name

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'wPLI');            %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'wPLI');           %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);

end


function testCutFrequencies_wPLI(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'wPLI');
    verifyEqual(testCase, resp, -1);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);                                              %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'wPLI');
    verifyEqual(testCase, resp, -1);
    w = loadFromDisk(append(dir, 'wPLI\', file_name));
    verifyEmpty(testCase, w);                                              %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_mutual_information(testCase)

    global fs cf dir file_name
    
    resp = connectivity(fs, cf, 5, 20, dir, 0,'mutual_information');
    verifyEqual(testCase, resp, 0);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);                                             %verify too many epochs, last column should be zero

    resp = connectivity(fs, cf, 1, 70, dir, 0,'mutual_information');
    verifyEqual(testCase, resp, -1);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);                                             %verify too long windows, single column should be zero
    
    resp = connectivity(fs, cf, 3, 20, dir, 70, 'mutual_information');
    verifyEqual(testCase, resp, -1);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);                                             %verify too long windows, should be a matrix of zeros

end


function testSamplingFrequency_mutual_information(testCase)

    global cf n_ep dt t_start dir

    resp = connectivity(0, cf, n_ep, dt, dir, t_start, 'mutual_information');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);

    resp = connectivity([], cf, n_ep, dt, dir, t_start, 'mutual_information');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);

end


function testCutFrequencies_mutual_information(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = connectivity(fs, [0], n_ep, dt, dir, t_start, 'mutual_information');
    verifyEqual(testCase, resp, -1);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);                                                        %verify cut frequencies zero, data should be empty

    resp = connectivity(fs, [], n_ep, dt, dir, t_start, 'mutual_information');
    verifyEqual(testCase, resp, -1);
    mi = loadFromDisk(append(dir, 'mutual_information\', file_name));
    verifyEmpty(testCase, mi);                                                        %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end