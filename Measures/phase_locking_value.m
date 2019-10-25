%% phase_locking_value 
% This function computes the phase locking value (PLV) between the signals 
% of different channels or ROIs in the input matrix
%
% PLV=phase_locking_value(sig)
%
% INPUT:
%   sig is the input matrix (in the format time*locations)
%
% OUTPUT:
%   PLV is the matrix of the phase locking value

function PLV=phase_locking_value(sig)
 
    nLoc=size(sig,2); 
    PLV=zeros(nLoc,nLoc); 
    complex_sig=hilbert(sig); 
    for i=1:nLoc     
        for j=1:nLoc      
            if i<j 
            PLV(i,j)=abs(mean(exp(1i*(unwrap(angle(complex_sig(:,i)))-unwrap(angle(complex_sig(:,j))))),1));
            PLV(j,i)=PLV(i,j);              
            end
        end
    end
end