function accuracy = accuracyInTimeBin(data,epoch,variableName,errorFunc)

K_FOLD = 10;
BIN_SIZE = 300;
JUMP_SIZE = 50;

boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
if strcmp(data.info.task,'choice')
    boolFail = [data.trials.fail] | ~[data.trials.choice] |...
        ~[data.trials.previous_completed];
end

raster_params.smoothing_margins = 0;
raster_params.align_to = epoch;
ts = -399:JUMP_SIZE:1200;


ind = find(~boolFail);

[groups, groupNames] = createGroups(data,epoch,ind,false,false,...
    false);

labels = groups{strcmp(groupNames,variableName)};
crossValSets = getNonOverlappingPartions(1:length(ind),K_FOLD);

accuracy = nan(1,length(ts));

for t=1:length(ts)

    tb = ts(t)-ceil(BIN_SIZE/2);
    te = ts(t)+ceil(BIN_SIZE/2);

    raster_params.time_before = -tb;
    raster_params.time_after = te;

    raster = getRaster(data,ind,raster_params);


    accuracy(t) = trainAndTestClassifier...
        ('PsthDistance',raster,labels,crossValSets);
end

a=5;

end