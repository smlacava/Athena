%This function load data from disk
%Many Athena functions use disk instead of cache to save the big amount of data returned

function data = loadFromDisk(file_dir)

    try
        data = load(file_dir);
        data = struct2cell(data);
        data = data{1}.data;
    catch
        data = [];
    end

end