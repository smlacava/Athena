%% 1) column table with last group and split

%-split
cvpt = cvpartition(groupData.group,"Holdout",0.35);
dataTrain = groupData(training(cvpt),:);
dataTest = groupData(test(cvpt),:);
%% 2) build a tree model
md1 = fitctree(dataTrain, "group");

%% 3) prune
prunedTreeModel = prune(mdl, "Level", integer);

%% 4)compute data loss
errPruned = loss(prunedTreeModel, dataTest);


%% 5) Visualizzazione modello e dei gruppi predetti
view(treeModel,"mode","graph");
plotGroup(groupData,groupData.group,"x")
