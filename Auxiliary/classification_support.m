%% classification_support
% This function returns a matrix to copy in a file excell to give the data 
% table to use as data in a classificator
%
% [dataOut]=neuropredict_support(dataIn)
%   output:
%       dataOut contains the matrix to copy in the csv file (if there are
%           more bands and more locations, the matrix will be composed as
%           every locations for the first band, every location for the
%           second band, etc.)
%
%   input:
%       dataIn is the matrix subjects*bands, subject*locations or
%           subjects*bands*locations to manage


%% controlare EXP
function [dataOut]=classification_support(dataIn)
    m=size(dataIn,2);
    sub=size(dataIn,1);
    if length(size(dataIn))==2
        n=1;
    else
        n=size(dataIn,3);
    end
    dataOut=zeros(sub,m*n);
    count=1;
    for i=1:n
    	for j=1:m
            for s=1:sub
                if abs(dataIn(s,j,i))>=0.0001
                    dataOut(s,count)=dataIn(s,j,i);
                end
            end
            count=count+1;
        end
    end
end