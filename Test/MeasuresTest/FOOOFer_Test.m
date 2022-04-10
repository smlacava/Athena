%This unit test the autocorrelation_measures function. Recommended use a .mat signal named 
%signal.mat (time serie index must be named data) in Example folder
%This functions test the output of the autocorrelation_measures function for different input
%parameters. Change outTypes for different entropy measures
%fs sample frequency
%cf cut frequencies
%n_ep number of epochs
%dt time window
%dir directory
%t_start starting time
%outTyeps type of measure


function tests = FOOOFer_Test

    tests = functiontests(localfunctions);

end


function setupOnce(testCase)

    global fs cf n_ep dt t_start band dir file_name series
    
    [cf,n_ep,dt,t_start,band,dir,file_name] = load_test_parameters("parameters.csv");

    signal = load(append(dir, file_name));
    series = signal.data.time_series;           %time series
    fs = signal.data.fs;                        %sample frequency

    for x = {'Offset', 'Exponent'}
        
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
    
    for x = {'Offset', 'Exponent'}
    
        delete(append(dir, x{1}, '\*'));

        try
            rmdir(append(dir,  x{1}));
        catch
        end

    end
    
end


function testoutTypes_FOOOFer(testCase)

    global fs cf n_ep dt t_start dir file_name
    
    resp = FOOOFer(fs, cf, n_ep, dt, dir, t_start, 1);
    verifyEqual(testCase, resp, -1);
    bk = loadFromDisk(append(dir, '1\', file_name));
    verifyEmpty(testCase, bk);                                                                %verify bad out type, data should be empty

    resp = FOOOFer(fs, cf, n_ep, dt, dir, t_start,'wrong');
    verifyEqual(testCase, resp, -1);
    bk = loadFromDisk(append(dir, 'wrong\', file_name));
    verifyEmpty(testCase, bk);                                                                %verify wrong out type, data should be empty

end


function testTimeAndEpochs_offset(testCase)

    global fs cf dir file_name
    
    resp = FOOOFer(fs, cf, 5, 20, dir, 0,'OFF');
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);                                                            %verify too many epochs, should be empty

    resp = FOOOFer(fs, cf, 1, 70, dir, 0,'OFF');
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);                                                            %verify too long windows, should be empty

    resp = FOOOFer(fs, cf, 3, 20, dir, 70, 'OFF');
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);                                                            %verify too long windows, should be empty

end


function testSamplingFrequency_offset(testCase)

    global cf n_ep dt t_start dir file_name

    resp = FOOOFer(0, cf, n_ep, dt, dir, t_start, 'OFF');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);

    resp = FOOOFer([], cf, n_ep, dt, dir, t_start, 'OFF');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);

end


function testCutFrequencies_offset(testCase)

    global fs n_ep dt t_start dir series file_name
    
    resp = FOOOFer(fs, [0], n_ep, dt, dir, t_start, 'OFF');
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);                                             %verify cut frequencies zero, data should be empty

    resp = FOOOFer(fs, [], n_ep, dt, dir, t_start, 'OFF');
    verifyEqual(testCase, resp, -1);
    off = loadFromDisk(append(dir, 'Offset\', file_name));
    verifyEmpty(testCase, off);                                             %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end


function testTimeAndEpochs_exponent(testCase)

    global fs cf dir file_name
    
    resp = FOOOFer(fs, cf, 5, 20, dir, 0,'EXP');
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);                                                            %verify too many epochs, should be empty

    resp = FOOOFer(fs, cf, 1, 70, dir, 0,'EXP');
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);                                                            %verify too long windows, should be empty

    resp = FOOOFer(fs, cf, 3, 20, dir, 70, 'EXP');
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);                                                            %verify too long windows, should be empty

end


function testSamplingFrequency_exponent(testCase)

    global cf n_ep dt t_start dir file_name

    resp = FOOOFer(0, cf, n_ep, dt, dir, t_start, 'EXP');         %verify sampling frequency zero, data should be empty
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);

    resp = FOOOFer([], cf, n_ep, dt, dir, t_start, 'EXP');        %verify sampling frequency null, data should be empty
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);

end


function testCutFrequencies_exponent(testCase)

    global fs n_ep dt t_start dir series file_name

    resp = FOOOFer(fs, [0], n_ep, dt, dir, t_start, 'EXP');
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);                                             %verify cut frequencies zero, data should be empty

    resp = FOOOFer(fs, [], n_ep, dt, dir, t_start, 'EXP');
    verifyEqual(testCase, resp, -1);
    exp = loadFromDisk(append(dir, 'Exponent\', file_name));
    verifyEmpty(testCase, exp);                                             %verify cut frequencies empty, data should be empty

    %for k = 1:n_ep
    %    for j = 1:size(series, 1)
    %        data = squeeze(series(j, dt*(k-1)+1:k*dt));
    %       
    %    end
    %end

end