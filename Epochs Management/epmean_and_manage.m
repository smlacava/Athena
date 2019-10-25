%% epmean_and_manage
% This function computes the epochs mean of the data matrices and saves
% a single data matrix for the patients (PAT) and another one for the 
% healthy controls (HC)
% 
% []=epmean_and_manage(inDir, type, subFile)
%
% input:
%   inDir is the data directory 
%   type is the measure type (offset, plv, aec, etc.)
%   subFile is the file which contains the subjects list with their class
%   (0=PAT, 1=HC)

function []=epmean_and_manage(inDir, type, subFile)

    type=string(type);
    inDir=path_check(inDir);


    fil='*.mat';
    cases=dir(fullfile(inDir,fil));
    Subjects=load_data(subFile);
    nSUB=length(Subjects);
    nPAT=sum(double(Subjects(:,end)));
    nHC=nSUB-nPAT;
    
    
    % setup
    data=load_data(strcat(inDir,cases(1).name));
    if sum(strcmp(type,["offset";"OFF";"off";"OFFSET"]))
        type = "OFF";
        nEp = size(data,1);
        nLoc = size(data,2);
        nBands = 1;
        HC=zeros(nHC,nBands,nEp,nLoc);
        PAT=zeros(nPAT,nBands,nEp,nLoc);
    elseif sum(strcmp(type,["exponent";"EXP";"exp";"EXPONENT"]))
        type = "EXP";
        nEp = size(data,1);
        nLoc = size(data,2);
        nBands = 1;
        HC=zeros(nHC,nBands,nEp,nLoc);
        PAT=zeros(nPAT,nBands,nEp,nLoc);
    elseif sum(strcmp(type,["psd";"PSD";"psdr";"PSDr"]))
        type = "PSD";
        nEp = size(data,2);
        nLoc = size(data,3);
        nBands = size(data,1);
        HC=zeros(nHC,nBands,nEp,nLoc);
        PAT=zeros(nPAT,nBands,nEp,nLoc);
    elseif sum(strcmp(type,["pli";"PLI";"Pli";"PLV";"plv";"Plv";"AEC";...
            "AECo";"AECc";"aec";"aecc";"aeco";"Aec";"Aecc";"Aeco";...
            "Conn";"CONN";"conn"]))
        type = "CONN";
        nEp = size(data,2);
        nLoc = size(data,3);
        nBands = size(data,1);
        HC=zeros(nHC,nBands,nEp,nLoc,nLoc);
        PAT=zeros(nPAT,nBands,nEp,nLoc,nLoc);
    end
    


    countPAT=1;
    countHC=1;
	for i=1:length(cases)
        data=load_data(strcat(inDir,cases(i).name));
        for k=1:nSUB
            if strcmp(string(Subjects(k,1)),cases(i).name(1:3))
                if Subjects(k,end)==1 %pat
                    if strcmp(type,'CONN')
                        PAT(countPAT,:,:,:,:)=data;
                    else
                        PAT(countPAT,:,:,:)=data;
                    end
                    countPAT=countPAT+1;
                else %hc
                    if strcmp(type,'CONN')
                        HC(countHC,:,:,:,:)=data;
                    else
                        HC(countHC,:,:,:)=data;
                    end
                    countHC=countHC+1;
                end
            end
        end
    end
   
   HC=squeeze(mean(HC,3));
   PAT=squeeze(mean(PAT,3));
   if not(exist(strcat(inDir,'Epmean')))
        mkdir(inDir,"Epmean")
   end
   save(strcat(inDir, 'Epmean\', 'HC_em'),'HC')
   save(strcat(inDir, 'Epmean\', 'PAT_em'),'PAT')
end